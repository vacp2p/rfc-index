# LOGOS-MODULE-RUNTIME

| Field        | Value                 |
|--------------|-----------------------|
| Name         | Logos Module Runtime  |
| Slug         | 205                   |
| Status       | raw                   |
| Category     | Standards Track       |
| Editor       | ksr                   |
| Contributors | Jarrad, atd           |

## Abstract

This specification defines how Logos modules are loaded, discovered,
connected, and managed at runtime. It covers:

- The dynamic module loading mechanism
- The service registry (how the runtime knows which modules exist)
- Module routing (how a call from module A reaches module B)
- Event subscription (how modules publish and receive events)
- Process isolation models (multi-process vs single-process)
- Module lifecycle (unloaded -> loaded -> ready -> stopping -> unloaded)
- Runtime-control interface for privileged runtime-host lifecycle control
- Threading and concurrency model
- Streaming and large data (acknowledged gap)

This spec does NOT define the module interface format (see
LOGOS-MODULE-INTERFACE) or the socket wire protocol (see
LOGOS-MODULE-TRANSPORT).

This spec also does NOT define host-application-specific launcher plumbing
such as package scanning policy, GUI-framework process management, or any
particular auth-token handoff mechanism between a runtime host and a spawned
module process. A concrete host MAY implement such mechanisms, but they are
deployment concerns rather than part of the reusable module-runtime contract.

### Execution-Boundary Preservation

LOGOS-MODULE-INTERFACE defines the execution-boundary invariant of the module
contract.

This runtime specification does not restate that invariant in full.
Its requirement is operational:

- the runtime MAY realize a module through direct, socket, or remote mode,
- but it MUST preserve the same module contract semantics when doing so.

In other words, routing mode is a runtime concern.
Changing execution boundary MUST NOT silently change the interface contract
observed by callers.

Direct mode has two binding forms:

- **Dynamic direct mode:** the module is loaded from a dynamic library, and the
  runtime resolves the mandatory C symbols with `dlopen` / `dlsym` or an
  equivalent platform mechanism.
- **Static direct mode:** the module is linked into the application or runtime
  binary, and the runtime obtains addresses for the same mandatory C symbols
  through build-time or startup integration.

## 1. Module Structure

### 1.1 What a Module Is

A module is a shared library (`.so`, `.dylib`, `.dll`) or a standalone
executable that:

1. Exports a set of well-known C symbols (defined in LOGOS-MODULE-INTERFACE
   section 2.6)
2. Ships a CDDL schema file describing its interface
3. Can be loaded by the runtime and connected to other modules

### 1.2 Required Exports

LOGOS-MODULE-INTERFACE is the normative owner of the module shared-library C
ABI.
A runtime implementation MUST treat every symbol classified there as mandatory
as a required load/bind symbol for native shared-library modules.
If any mandatory symbol is missing, the runtime MUST reject the module with a
descriptive error.

In these symbol names, `<module>` is the module's flat runtime module name as
defined in section 1.3.

Symbols classified as optional or well-known extension symbols are not required
for every module.
When present, the runtime MUST bind and use them according to their defining
Runtime section.

Version metadata is not canonical schema identity;
structural schema identity is defined by LOGOS-MODULE-COMMITMENT-MODEL.

### 1.3 Module Naming

Module names are non-empty UTF-8 strings matching `[a-z][a-z0-9_]*`, with a
maximum length of 64 bytes. Examples: `storage_module`, `capability_module`,
`delivery_module`.

This revision intentionally uses flat runtime module names.
The module name is an operational runtime identifier used for lookup, socket
naming, and C ABI symbol derivation.
It is not, by itself, a complete global package identity or cryptographic
schema identity.

Names beginning with `logos_` are reserved for Logos-defined runtime and
system modules.
Exact flat module names assigned by a Logos specification, package catalog, or
registry are reserved for that assigned module.

The name is used to:
- Derive socket paths: `<runtime-dir>/logos_<name>.sock`
- Derive C symbol prefixes: `logos_<name>_*`
- Look up modules in the service registry

---

## 2. Plugin Loading

### 2.1 Dynamic Loading

On platforms that support dynamic loading (Linux, macOS, Windows desktop), the
runtime loads modules using the platform's dynamic linker:

- Linux/macOS: `dlopen(path, RTLD_NOW | RTLD_LOCAL)`
- Windows: `LoadLibrary(path)`

When the runtime already knows the module name from a manifest, command-line
argument, package metadata, or another host record, it constructs the
module-prefixed symbol names directly:

```c
void* lib = dlopen("storage_module.so", RTLD_NOW | RTLD_LOCAL);

/* Known-name load path: storage_module is already known. */
typedef const char* (*schema_fn)(void);
schema_fn get_schema = (schema_fn)dlsym(lib, "logos_storage_module_schema");

/* ... etc for _name, _version, _init, _destroy, and per-method C symbols */
```

If any required symbol is missing, the module MUST be rejected with a
descriptive error.
If the runtime does not know the module name before loading, it uses the
bootstrap strategy in section 2.2.

### 2.2 Symbol Discovery Convention

Because the module prefix contains the module name (which the runtime may not
know before loading), there are two discovery strategies:

**Strategy A: Known name.** The runtime knows the module name (from a
manifest, command-line argument, or package metadata) and constructs the
symbol names directly: `logos_<known_name>_name`, etc.

**Strategy B: Bootstrap symbol.** For cases where the runtime loads an
unknown `.so`, the module MAY export a generic bootstrap symbol:

```c
/* Optional: allows loading without knowing the module name in advance */
const char* logos_module_name(void);
```

This returns the module name, which the runtime then uses to look up the
remaining prefixed symbols.

Modules SHOULD export the bootstrap symbol. The runtime MUST support both
strategies.

### 2.3 Static Direct Mode

On platforms where dynamic loading is unavailable or undesirable, modules MAY be
statically linked into the application or runtime binary.
This is static direct mode.

Static direct mode MUST bind the same mandatory C symbols defined by
LOGOS-MODULE-INTERFACE.
This includes metadata, lifecycle, schema, module deallocation, and
schema-derived per-method C symbols.
If a module exposes optional well-known callback setters, static direct mode
MUST make those setters available through the selected binding mechanism.

The binding mechanism is implementation-defined and MAY be generated by a module
kit.
Common mechanisms include generated registration tables, generated static symbol
resolvers, linker-section registration, or application startup code that passes
known function pointers to the runtime.

Static direct mode MUST NOT define a second callee-side module interface.
It is a binding mechanism for the mandatory C module interface.

Applications using static direct mode MUST make the module bindings available
before `logos_runtime_start()`.

### 2.4 Standalone Transport Module

A module MAY run as a standalone executable that implements
LOGOS-MODULE-TRANSPORT directly rather than as a shared library loaded by a
module host process.
In this mode:

- The module binary starts, binds a Unix domain socket or TCP port, and
  listens for Logos deterministic CBOR requests per LOGOS-MODULE-TRANSPORT.
- The runtime connects to the module as a client.
- The module does not need to expose the shared-library C ABI, because it
  implements the transport endpoint itself.

This mode is useful for modules written in languages that don't produce
shared libraries (e.g. a Go module, a JVM module).

Security requirements for standalone transport modules are the same as for any
out-of-process transport module:

- the runtime MUST authenticate the peer according to the active runtime
  security policy,
- the transport connection MUST satisfy the requirements of
  LOGOS-MODULE-TRANSPORT for local or remote mode, and
- the execution mode MUST NOT weaken the module contract or bypass normal
  authorization and routing rules.

### 2.5 Introspection

A running module's interface can be introspected at runtime by calling
`logos_<module>_schema()`, which returns the CDDL schema as a string. This
enables:

- Runtime type checking of calls
- Auto-generation of client stubs
- UI-based module browsers
- Remote module discovery

In socket mode, the schema is also available via the well-known
`logos.schema` method (defined in `logos_common.cddl`, see
LOGOS-MODULE-INTERFACE section 5.1). This method is provided automatically
by the runtime and codegen tool — module authors do not declare it.

---

## 3. Service Registry

### 3.1 Purpose

The service registry maps module names to their locations (socket paths,
in-process registration records, or remote addresses).
It is the runtime's answer to the question:
"Where is module X?"

### 3.2 Registry Implementation

The registry is a simple in-memory table maintained by the runtime:

```
module_name  ->  {
    state:       unloaded | loaded | ready | stopping | error
    mode:        direct | socket | remote
    location:    <function pointers>  (direct mode)
                 <socket path>        (socket mode)
                 <host:port>          (remote mode)
    schema:      <CDDL string>
    schema_namespace: <schema namespace>
    schema_commitment: <schema commitment, when known>
    version:     [major, minor]
    pid:         <process id>         (socket mode only)
}
```

### 3.3 Runtime Module Binding

A runtime registry entry is a runtime module binding.
It binds the operational module name used for loading and routing to the
schema contract that the runtime expects that module to implement.

The binding contains:

- the flat runtime module name;
- the execution mode and load or connection location;
- the compatibility version expectation, when known;
- the module schema text or another way to obtain it;
- the primary schema namespace for the module schema;
- the expected schema commitment, when known.

The flat runtime module name is the operational identifier defined in Section
1.3.
The schema namespace and schema commitment are structural contract identifiers
defined by LOGOS-MODULE-COMMITMENT-MODEL.
They are distinct identifiers and MUST NOT be treated as interchangeable.

A runtime MUST NOT infer schema compatibility from spelling similarity between
the runtime module name and the schema namespace.
For example, `storage_module` and `storage` are related only if the registry
entry, host record, package metadata, or another trusted configuration source
binds them to the same module contract.

When a registry entry includes an expected schema commitment, the runtime MUST
compare the loaded or connected module's declared schema commitment against the
expected commitment before treating the module as ready.
For direct modules, the runtime derives or obtains the module's schema
commitment from the schema returned by `logos_<module>_schema()`.
For socket or remote modules, the runtime obtains the peer's declared schema
commitment from the Transport Hello `schema` field.

If the expected schema commitment is present and the loaded or connected
module declares a different schema commitment, the runtime MUST reject the
module for that registry entry and MUST NOT route ordinary calls to it.
If no expected schema commitment is present, the runtime MAY record the
module's declared schema commitment for diagnostics, later policy decisions,
or caller-visible introspection.

This specification defines the runtime binding and the checks the runtime
performs against it.
It does not define package signatures, artifact digests, catalog trust,
update policy, or the on-disk manifest schema that may supply the binding.
Those topics belong to deployment, package, or trust specifications.

### 3.4 Module States

```
                 load()              init() returns OK
  [unloaded] ──────────> [loaded] ──────────────────> [ready]
                             |                           |
                             v                           v
                          [error]                    [stopping]
                                                        |
                                          destroy()     v
                                                    [unloaded]
```

- **unloaded:** Module is known (from config/manifest) but not loaded.
- **loaded:** `dlopen` succeeded; `_init()` not yet called or in progress.
- **ready:** `_init()` returned `LOGOS_OK`. The module is now runtime-ready:
  the runtime MAY route calls to it and the module MUST be able to accept
  requests and return protocol-valid success or error responses.
- **stopping:** `_destroy()` has been called; waiting for cleanup.
- **error:** Loading or initialisation failed. Error details available.

There is no separate "running" state. A module in `ready` state accepts
calls. The runtime tracks active call count internally for graceful shutdown
but this is not a module state.

**Important distinction: runtime-ready vs application-ready.**

The lifecycle symbol `logos_<module>_init(void)` is runtime/loader
initialisation only. It establishes that the shared library has loaded
correctly and is ready to participate in the runtime contract, including
method invocation, publish hook installation, and outbound-call hook
installation.

It does **not** imply that all schema-defined methods will succeed
immediately. A module MAY still require one or more ordinary schema methods
such as `init`, `start`, login/session establishment, or similar
application-level setup before its full business functionality is available.
Until that setup is complete, schema-defined methods MAY return
`LOGOS_ERR_NOT_READY`.

Therefore:

- the runtime transitions to `ready` after successful lifecycle `_init()`
- the runtime MAY route requests to the module in that state
- callers MUST still handle per-method `LOGOS_ERR_NOT_READY` responses
- method-level readiness is part of the module's schema/API semantics, not a
  separate runtime lifecycle state

### 3.5 Discovery Sources

The runtime registry can be populated from several sources:

1. **Resolved host records.** A runtime host, package manager, or deployment
   tool may hand the runtime a resolved module name, artifact path, runtime
   mode, version expectation, schema namespace expectation, schema commitment
   expectation, and dependency closure.
2. **Resolved local records.** A deployment profile or local runtime setup may
   provide already-resolved module records for a concrete runtime instance.
3. **Self-describing plugin scan.** A runtime may scan one or more directories
   for `.so`/`.dylib` files and probe each using the bootstrap symbol
   (see section 3.6).
4. **Runtime registration.** For static linking or test scenarios, modules
   may be registered programmatically via `logos_runtime_register_module()`.

The on-disk package or module manifest schema is outside this specification.
It belongs to a future deployment specification or to package-manager input
contracts.
The package-manager catalog output shape also belongs outside this runtime
specification.
The runtime consumes resolved records and maintains loaded runtime state.

### 3.6 Plugin Directory Scanning

When scanning a plugin directory without trusted sidecar metadata, the runtime
probes each `.so`/`.dylib` file to extract metadata. The probe uses `dlopen`
+ `dlsym` — no framework-specific metadata embedding is required.

**Probe procedure:**

```
for each .so file in plugin_dir:
    1. handle = dlopen(path, RTLD_NOW | RTLD_LOCAL)
       if failed: skip (not a valid shared library)

    2. name_fn = dlsym(handle, "logos_module_name")
       if not found: dlclose, skip (not self-describing)

    3. name = name_fn()
       if empty or invalid: dlclose, skip

    4. Look up optional metadata symbols:
       - logos_<name>_version()  -> compatibility version metadata
       - logos_<name>_schema()   -> CDDL schema text

    5. Register in service registry:
       { name, path, version, schema, state: unloaded }

    6. dlclose(handle)  -- module is not loaded yet, only discovered
```

This self-describing scan path has no dependency on application-framework
plugin loaders or embedded JSON metadata.
Any shared library that exports `logos_module_name()` is discoverable without
knowing its module name in advance.

**The bootstrap symbol `logos_module_name()` is the sole requirement for
self-describing discovery.** Version and schema symbols are optional at
discovery time (they can be queried after loading). This keeps the bar low for
module authors: export one function, and the runtime finds you.

This does not make `logos_module_name()` mandatory for every load path.
If the runtime already knows the module name from a resolved host record,
static registration table, command-line argument, or equivalent
host/deployment metadata, it MAY construct the prefixed lifecycle symbol names
directly as described in section 2.2.

### 3.7 Module Dependencies

Module dependencies are deployment facts, not CDDL interface facts.
A package manifest or package-manager catalog may declare dependencies on
other modules.
Such fields are outside this runtime specification until a deployment
specification or package-manager CDDL defines them.

```json
{
    "name": "delivery_module",
    "dependencies": ["storage_module", "capability_module"]
}
```

The dependency field name for new Logos manifests and catalogs should be
`dependencies`.
Implementations MAY accept `depends` as a deprecated compatibility alias in
private or transitional tooling.

When the runtime is asked to start a dependency closure, every dependency in
that resolved closure MUST be loaded and initialised before the dependent
module's `_init()` is called.
Dependency graph construction, missing-dependency detection, and cycle
detection belong to the package manager or host/deployment layer unless a
future deployment specification assigns those responsibilities differently.

---

## 4. Module Routing and Handle Acquisition

### 4.1 Connecting to a Module

A module (or the application) obtains a handle to another module via the
runtime:

```c
logos_module_handle_t* logos_runtime_connect(const char* module_name);
void                   logos_runtime_disconnect(logos_module_handle_t* h);
```

The runtime consults the registry to determine the target module's mode:

- **Direct mode:** Returns a handle wrapping function pointers to the target
  module's C API. Calls go through direct C function invocation. No
  serialisation.
- **Socket mode:** Returns a handle wrapping a socket connection to the
  target module's host process. Calls are serialised as CBOR per
  LOGOS-MODULE-TRANSPORT.
- **Remote mode:** Same as socket mode, but over TCP/TLS to a remote host.

The caller does not know or care which mode is active. The handle abstraction
hides the transport.
Handle-based typed client helpers are the portable caller-side C API.
Such helpers take a `logos_module_handle_t*` as their first argument and route
calls through the handle.

The purpose of the handle abstraction is precisely to preserve the execution-
boundary equivalence stated above: the runtime may switch routing mode, but
the module contract observed by the caller remains the same.

For a module method such as `storage.exists`, a generated handle-based client
helper may have this shape:

```c
logos_result_t logos_storage_exists(
    logos_module_handle_t* h,
    const char*            cid,
    bool*                  out_exists
);
```

This caller-side helper is distinct from the callee-side Logos module C
function defined by LOGOS-MODULE-INTERFACE.

A runtime MAY also expose a generic dynamic call API for callers that discover
schemas at runtime or do not have generated typed client helpers:

```c
logos_result_t logos_runtime_call(
    logos_module_handle_t* h,
    const char*            method,
    const uint8_t*         params_cbor,
    size_t                 params_len,
    uint8_t**              response_cbor,
    size_t*                response_len
);
```

The generic call API carries deterministic-CBOR method payloads using the same
request, response, and error shapes as LOGOS-MODULE-TRANSPORT.

A singleton direct-call profile MAY additionally generate no-handle convenience
helpers as described in section 5.2.1.

### 4.2 Routing Table

The runtime maintains a routing table mapping (caller, callee) pairs to
transport configurations:

| Caller | Callee | Mode | Notes |
|--------|--------|------|-------|
| (any) | storage_module | socket | Default: separate process |
| presenter | storage_module | direct | Mobile: same process |
| (any) | capability_module | direct | Always in-process for security |

The routing table is populated from configuration. The runtime MAY change
routes at runtime (e.g. switching from remote to local when a module becomes
available locally).

### 4.2.1 Routing View For Socket-Hosted Module Processes

When a module runs in **socket mode**, the module host process is still part of
the same logical runtime routing domain. Therefore, if that host exposes
`logos_<module>_set_call_module()`, it MUST be able to resolve outbound calls
using a routing view that is consistent with the runtime's current registry and
routing-table semantics.

This requirement is semantic, not architectural. The spec does **not** require
a specific mechanism. A conforming implementation MAY satisfy it by, for
example:

- giving the module host a local copy or snapshot of the relevant routing data
- providing the module host a runtime-managed lookup/control channel
- embedding the host in a larger runtime process that already has the routing
  table in memory

What matters normatively is:

- a socket-hosted module MUST NOT need to invent its own independent routing
  policy
- outbound calls from a socket-hosted module MUST be resolved according to the
  same runtime registry/routing rules that would apply if the caller were
  in-process
- if the implementation allows routing changes at runtime, it MUST define a
  consistency model such that hosts do not silently route according to stale or
  contradictory information

The consistency mechanism itself is implementation-defined. The interoperable
requirement is the observable behavior at the module boundary, not the control
plane used to achieve it.

### 4.3 Capability Validation

Before returning a handle, the runtime MUST verify that the caller is
authorised to access the callee according to the active runtime policy.

This specification does not define the capability token format, capability
issuance flow, or policy language for module-to-module access.
A future capability or trust specification may define a portable module
contract for those decisions.
Until such a profile is selected, the runtime MUST treat authorization as a
local policy decision and MUST NOT infer permission merely from module names,
schema names, or successful transport connection.

### 4.4 Event Subscription via Handle

The handle provides generic event subscription:

```c
logos_result_t logos_runtime_subscribe(
    logos_module_handle_t* h,
    const char*            event_name,
    logos_event_handler_t  handler,
    void*                  user_data,
    uint64_t*              out_subscription_id
);

logos_result_t logos_runtime_unsubscribe(
    logos_module_handle_t* h,
    uint64_t               subscription_id
);
```

Where:

```c
typedef void (*logos_event_handler_t)(
    const char*    event_name,
    const uint8_t* cbor_data,       /* CBOR-encoded event map */
    size_t         cbor_data_len,
    void*          user_data
);
/* cbor_data is valid only for the duration of the callback.
 * Handlers MUST copy the data if they need to retain it. */
```

In **direct mode**, the module publishes events by calling a runtime-provided
publish function. The runtime delivers to local subscribers by invoking their
handlers directly.

In **socket mode**, subscriptions are translated to Subscribe messages
(message kind 3) per LOGOS-MODULE-TRANSPORT.
Incoming Event messages (message kind 5) are decoded and delivered to the
handler.

The codegen tool MAY generate typed event subscription helpers that decode
the CBOR and call a typed callback:

```c
/* Generated typed helper */
logos_result_t logos_storage_on_upload_progress(
    logos_module_handle_t* h,
    void (*handler)(const logos_storage_upload_progress_event_t*, void*),
    void* user_data,
    uint64_t* out_subscription_id
);
```

These are convenience wrappers over the generic subscription API.

---

## 5. Process Model

### 5.1 Multi-Process (Desktop Default)

Each shared-library module runs in its own OS process by default.
The runtime (`liblogos`) spawns a **module host** process for each such module:

```
logos_host --module <path-to-module.so> --socket <socket-path>
```

The module host:

1. `dlopen`s the module shared library
2. Calls lifecycle `_init()` (this revision passes no typed configuration)
3. Binds the Unix domain socket
4. Enters an event loop, reading CBOR requests from the socket, creating an
   opaque `logos_call_context_t` for each invocation, invoking the corresponding
   schema-derived C method, and writing responses

In this multi-process shared-library mode, the runtime communicates with the
module host over LOGOS-MODULE-TRANSPORT, while the module host executes the
module through the C ABI symbols defined by LOGOS-MODULE-INTERFACE.
`dlopen`/`dlsym` are used inside the module host process, not across the socket
connection.

Benefits:
- Process isolation: a crashing module doesn't bring down others
- Resource accounting: per-module CPU/memory tracking via OS tools
- Security: modules can be sandboxed (seccomp, AppArmor, etc.)

### 5.2 Single-Process (Mobile / Embedded)

All modules are loaded into one process. Calls go through direct C function
pointers. No serialisation, no sockets.

The runtime still manages the registry, lifecycle, and capability validation.
The difference is only in the transport: direct calls instead of CBOR-over-
socket.

### 5.2.1 Singleton Direct-Call Profile

A runtime profile MAY define a singleton direct-call profile for direct mode.
The profile MAY be used with dynamic direct mode or static direct mode.

In this profile, each module name has at most one live module instance inside
the runtime instance.
Generated client helpers MAY omit `logos_module_handle_t*` and route calls
through the runtime's default binding for that module name.

This profile is intended for mobile, embedded, and simple packaged
applications where the module set is known at build or packaging time.

The profile MUST NOT change the module contract:
method names, request and response shapes, event names, error codes, lifecycle
rules, and authorization semantics remain the same as in the handle-based
runtime model.

A singleton direct-call profile MUST define:

- how the default runtime instance is selected;
- how module initialization order is determined;
- how duplicate module names are rejected;
- how generated no-handle helpers fail when the default module binding is not
  ready;
- whether outbound calls and event publishing use the same runtime callbacks as
  ordinary direct mode.

This profile is a convenience profile.
Portable code that needs multiple module instances, multiple runtimes in one
process, runtime-selected local/remote routing, or explicit test isolation
SHOULD use handle-based client helpers.

### 5.3 Hybrid

Some modules may run in-process (capability module, small utility modules)
while others run in separate processes (storage, heavy computation). The
routing table (section 4.2) determines the mode per-module.

---

## 6. Threading and Concurrency

### 6.1 Module Threading Model

Modules MUST be safe to call from multiple threads. The runtime MAY dispatch
requests to a module from different threads concurrently (e.g. when multiple
callers invoke the same module simultaneously).

Modules that cannot handle concurrent calls MUST implement their own internal
serialisation (e.g. a mutex). The runtime does not provide call serialisation.

### 6.2 Module Host Threading

In socket mode, the module host process runs an event loop that:

- Accepts connections from multiple callers
- Reads requests from all connections (via `poll`/`epoll`/`kqueue`)
- Supplies a `logos_call_context_t*` and invokes the corresponding
  schema-derived C method for each request

The runtime MUST NOT mark a socket-hosted module as `ready` merely because a
socket path exists.
The host is ready only after the runtime can connect to that socket and
complete the LOGOS-MODULE-TRANSPORT Hello handshake for the hosted module.
If readiness is not reached before the startup timeout, the runtime MUST
terminate the host process, remove any stale socket file it owns, and leave the
module out of the ready routing table.

The module host SHOULD use a thread pool for dispatching requests, so that
a slow method does not block other callers. The default pool size is
implementation-defined (recommended: number of CPU cores).

### 6.3 Event Delivery Threading

Event handlers (registered via `logos_runtime_subscribe`) are called on an
unspecified thread. Handlers MUST be thread-safe. Handlers MUST NOT block
for extended periods (they run on the runtime's event delivery thread).

For host applications with a dedicated UI thread, the runtime MAY provide a
mechanism to marshal event delivery to that thread.
The integration mechanism is framework-specific and not part of this spec.

### 6.4 Direct Mode Concurrency

In direct mode (in-process), calls execute on the caller's thread. The
module receives calls on whatever thread the caller is running on. This is
why modules MUST be thread-safe (section 6.1).

---

## 7. Event Loop

### 7.1 Runtime Event Loop

The runtime provides an event loop that:

- Accepts incoming socket connections from module host processes
- Dispatches incoming CBOR requests to the appropriate module
- Delivers events from modules to subscribers
- Handles module lifecycle transitions (start, stop, crash recovery)

The runtime event loop MAY integrate with an event loop owned by the host
application.
The integration mechanism is framework-specific and not part of this spec.
When no host event loop is provided, the runtime provides its own event loop.

### 7.2 Module Event Loop

Module host processes run their own event loop:

In the pseudocode below, `invoke_schema_method` is illustrative host behavior,
not a required exported symbol.
It means that the host decodes the transport request, identifies the requested
schema method, creates or reuses the call context for the invocation, calls the
corresponding native C function, and encodes the transport response.

```
while running:
    msg = read_framed_cbor(socket)
    response = invoke_schema_method(msg)
    write_framed_cbor(socket, response)
```

### 7.3 Module Event Publishing

A module publishes events by calling a runtime-provided function:

```c
typedef void (*logos_publish_fn)(
    void*          user_data,
    const char*    event_name,
    const uint8_t* cbor_data,
    size_t         cbor_data_len
);
```

`event_name` MUST be the exact schema event identifier from the module's
CDDL, for example `storage.started_event` or
`storage.upload_progress_event`.

The runtime delivers the event to all subscribers (local or remote). In
socket mode, the module host translates `logos_publish_fn` calls into Event
messages (message kind 5) on all connections with matching subscriptions.
If multiple caller connections have matching subscriptions, each connection
MUST receive an Event message for its own matching subscription IDs.

This publish path is for asynchronous one-way notifications with
schema-defined event payloads.
Modules use it for progress, completion, state-change, and similar signals.
It is not a general outbound method mechanism and does not replace normal
request/response dispatch.
Publishing an event does not create a response obligation for subscribers, and
modules MUST NOT model request/reply flows through events.

### 7.4 How Modules Receive the Publish Function

The publish function is provided via a **well-known symbol** that the
runtime calls after `_init()` succeeds:

The module stores the function pointer and user data internally.
If the module does not publish any events, it MAY omit this symbol — the
runtime MUST NOT fail if the symbol is absent.

```c
/* Exported by the module. Called by runtime/host after _init() returns OK. */
void logos_<module>_set_publish(logos_publish_fn fn, void* user_data);
```

`user_data` is opaque, process-local callback state supplied by the runtime or
module host.
The module MUST pass the value back unchanged when it calls `fn`.
The module MUST NOT dereference it, compare it for semantic identity, serialize
it, persist it, expose it in schemas, or send it across a transport or network
boundary.
It is meaningful only inside the process that installed the callback.

For compatibility with older generated modules that may still publish short
event names such as `started`, a runtime MAY normalize those legacy names
to the canonical schema event name before putting them on the wire. New
modules and code generators MUST use the canonical schema event name
directly.

For static direct mode, the selected binding mechanism makes the publish setter
available to the runtime before `logos_runtime_start()` (see section 2.3).
The runtime calls the publish setter after `_init()` succeeds and before the
module is considered ready.

Modules MUST NOT rely on the publish function being installed during `_init()`.

**Lifetime:** The publish function and its `user_data` are valid from the
time they are set until `_destroy()` returns or until the hook is replaced.
Modules MUST NOT call a previous hook after replacement and MUST NOT call any
hook after `_destroy()`.

**Thread safety:** The publish function is thread-safe. Modules MAY call
it from any thread.

### 7.5 Outbound Calls (Calling Other Modules)

A module that needs to call another module can do so through a runtime-
provided callback, without linking the SDK or implementing the transport
protocol's client side:

```c
/* Provided by the runtime to the module after _init() */
typedef void (*logos_free_response_fn)(void* user_data, void* ptr);

typedef logos_result_t (*logos_call_module_fn)(
    void*           user_data,
    const char*     target_module,
    const uint8_t*  request_cbor,    /* CBOR: {"method": tstr, "params": {...}} */
    size_t          request_len,
    uint8_t**       response_cbor,   /* runtime/callback allocates */
    size_t*         response_len
);

/* Exported by the module. Called by runtime/host after _init() returns OK. */
void logos_<module>_set_call_module(
    logos_call_module_fn   fn,
    logos_free_response_fn free_response,
    void*                  user_data
);
```

The module encodes a CBOR request map (`{method, params}`) for the target
module, calls the function, and receives a CBOR response.
The callback represents the runtime-owned outbound-call service for the
module's current placement.
It hides whether the target is in-process, hosted by another local process, or
remote.

This specification requires that outbound calls follow the runtime routing
model from sections 4.2 and 4.2.1.
It does not require every call to pass through a single central broker process.
For in-process modules, the callback may dispatch directly through cached
function pointers, generated stubs, or equivalent local dispatch state.
For socket-hosted modules, the callback may be installed by the per-module host
process and may translate the outbound call into transport requests using a
routing view supplied by, synchronized with, or otherwise authorized by the
runtime.
For remote targets, the callback may route through the appropriate remote
runtime binding.

The callback is runtime-owned in authority and semantics even when the concrete
function pointer is installed by a per-module host process.
A module MUST treat the callback as its only portable outbound-call mechanism
and MUST NOT infer topology from the callback implementation.

If `logos_call_module_fn` returns a non-null `response_cbor`, the module MUST
free it with the paired `logos_free_response_fn`.
This deallocator is owned by the runtime or module host that installed the
callback.
It is distinct from the callee module's `logos_<module>_free()` function.

If the module does not call other modules, it MAY omit this symbol. The
runtime MUST NOT fail if the symbol is absent.

`user_data` follows the same process-local callback-state rules as
`logos_publish_fn`.
For Level 1 transport placement, it remains inside the module host process:
the host callback translates the outbound call into transport requests and
responses, and only CBOR envelopes and payloads cross the process or network
boundary.
For Level 2 and Level 3 local placement, it similarly remains local glue state
for the runtime or host that installed the callback.

**Lifetime:** Same as `logos_publish_fn`.

**Thread safety:** The function is thread-safe. Modules MAY call it from
any thread. Calls are synchronous — the function blocks until the target
module responds.

**Error handling:** If the target module is not found, returns
`LOGOS_ERR_MODULE` with `*response_cbor = NULL`. If the target returns an
error, the error is encoded in `response_cbor` as an error-payload map
(`{code, message, ?detail}`).

---

## 8. Runtime Input Records

The runtime does not define a configuration file format.

A runtime instance consumes resolved module records supplied by a runtime host,
package-manager module, deployment profile, static registration API, or test
harness.
The producer of those records is outside this specification.

A resolved module record supplies the information needed to create or update a
runtime registry entry:

- the flat runtime module name;
- the execution mode;
- the load path, static registration handle, local transport endpoint, or
  remote transport endpoint;
- compatibility version expectations, when known;
- schema namespace expectation, when known;
- schema commitment expectation, when known;
- runtime-local options needed by the selected implementation.

The runtime MUST validate resolved module records before routing calls through
them.
If a record includes a schema commitment expectation, the runtime MUST apply
the schema-commitment checks defined in Section 3.3 before marking the module
ready.

This specification does not define package catalogs, install roots,
dependency-graph queries, trust decisions, action prompts, or persistent
configuration storage.
Those belong to package-manager, runtime-host, deployment, or trust
specifications.

### 8.1 Module Initialization Inputs

This revision defines the lifecycle initializer as `_init(void)`.
It does not define a typed runtime-configuration handoff through the lifecycle
ABI.

If a module needs configuration, the selected deployment or host profile must
arrange that configuration outside the lifecycle ABI, for example through
resolved runtime records, environment, local files, or module-specific methods.
A future specification may define a typed configuration handoff if it becomes
part of the portable runtime contract.

---

## 9. Runtime-Control Interface

The runtime owns module lifecycle machinery.
This specification also defines a Logos module interface for privileged
runtime-host/runtime-control operations.
The interface exposes runtime-owned lifecycle and observation operations
through the same CDDL-defined contract model as other Logos modules.

A runtime host is the local authority-bearing environment that creates,
embeds, launches, or otherwise controls a runtime instance.
A host shell is one kind of runtime host that provides a general user-facing
shell.
A standalone application MAY also be a runtime host for its own runtime
instance.
Runtime hosts MAY use the runtime-control interface, subject to active runtime
policy.
The runtime host is not required to be a Logos module.
It MAY expose Logos module interfaces, but its runtime-control authority comes
from the local host/runtime relationship or an explicitly granted policy, not
from ordinary module status.

The runtime-control surface operates on runtime-known module records.
It does not define package catalogs, install roots, dependency graph
resolution, trust decisions, or UI state.
Those remain package-manager, deployment, trust, or runtime-host concerns.

Runtime-control methods are privileged operations.
A runtime MUST authorize a caller according to the active runtime policy
before executing any runtime-control method.
A runtime MUST NOT expose this surface to ordinary modules or remote peers by
default.

This specification does not define a capability token format, token issuance
flow, policy language, or trust-store format.
Those mechanisms may be supplied by future capability, trust, deployment, or
runtime-host specifications.
Until such profiles are defined, runtime-control access is local privileged
host/runtime authority.

### 9.1 Runtime-Control Module Contract

The runtime-control interface is a Logos-defined system module surface.
Its flat runtime module name is `logos_runtime_control`.
Its schema namespace is `logos.runtime_control`.
Because both names are Logos-defined, they are allowed uses of the reserved
`logos_` and `logos.` namespaces.

```cddl
; -- metadata --
_module = "logos_runtime_control"
_version = [1, 0]

logos.runtime_control.module_name = tstr .size (1..64)
logos.runtime_control.instance_id = tstr .size (1..128)
logos.runtime_control.schema_namespace = tstr .size (1..128)
logos.runtime_control.reason = tstr .size (0..512)

logos.runtime_control.state =
    "unloaded" /
    "loaded" /
    "ready" /
    "stopping" /
    "error"

logos.runtime_control.mode =
    "direct" /
    "socket" /
    "remote"

logos.runtime_control.schema_commitment = {
    commitment_model: tstr,
    schema_root: bstr,
    hash_profile: tstr,
    hash_suite: tstr,
}

logos.runtime_control.module_record = {
    module: logos.runtime_control.module_name,
    ? instance: logos.runtime_control.instance_id,
    state: logos.runtime_control.state,
    mode: logos.runtime_control.mode,
    ? schema_namespace: logos.runtime_control.schema_namespace,
    ? schema: logos.runtime_control.schema_commitment,
    ? reason: logos.runtime_control.reason,
}

logos.runtime_control.list_modules_request = {}

logos.runtime_control.list_modules_response = {
    modules: [* logos.runtime_control.module_record],
}

logos.runtime_control.start_module_request = {
    module: logos.runtime_control.module_name,
    ? instance: logos.runtime_control.instance_id,
}

logos.runtime_control.start_module_response = {
    module: logos.runtime_control.module_name,
    instance: logos.runtime_control.instance_id,
    state: logos.runtime_control.state,
}

logos.runtime_control.stop_module_request = {
    module: logos.runtime_control.module_name,
    ? instance: logos.runtime_control.instance_id,
}

logos.runtime_control.stop_module_response = {
    module: logos.runtime_control.module_name,
    ? instance: logos.runtime_control.instance_id,
    state: logos.runtime_control.state,
}

logos.runtime_control.get_readiness_request = {
    module: logos.runtime_control.module_name,
    ? instance: logos.runtime_control.instance_id,
}

logos.runtime_control.get_readiness_response = {
    module: logos.runtime_control.module_name,
    ? instance: logos.runtime_control.instance_id,
    state: logos.runtime_control.state,
    ? reason: logos.runtime_control.reason,
}

logos.runtime_control.module_state_changed_event = {
    module: logos.runtime_control.module_name,
    ? instance: logos.runtime_control.instance_id,
    old_state: logos.runtime_control.state,
    new_state: logos.runtime_control.state,
    ? reason: logos.runtime_control.reason,
}
```

The `start_module` method starts a module record already known to the runtime.
If the module record is not known, the runtime returns the ordinary
schema-defined error result for "module not found" or equivalent runtime
failure.
The method does not install packages, resolve package dependencies, or create
new runtime records by itself.

If a runtime may have multiple live instances for the same module name, the
`instance` field disambiguates the target.
If no ambiguity exists, the caller MAY omit `instance`.

The `stop_module` method stops the selected module instance.
It does not perform package uninstall, dependency cascade confirmation, or
user prompting.
A runtime host may perform those workflows before calling `stop_module`.

The `get_readiness` method reports the runtime lifecycle state for the
selected module instance.
Method-level application readiness remains part of the module's own schema
semantics, as described in Section 3.4.

The `module_state_changed_event` event reports runtime lifecycle transitions
observed through this control surface.
It is not a replacement for schema-defined events published by ordinary
modules.

Because the runtime-control interface is an ordinary Logos module contract at
the schema layer, its schema and values are subject to
LOGOS-MODULE-COMMITMENT-MODEL and LOGOS-MODULE-HASH-PROFILE in the same way
as other module contracts.

---

## 10. Error Handling and Recovery

### 10.1 Module Crash Recovery

When a module host process crashes (detected via socket close or SIGCHLD),
the runtime:

1. Marks the module as `error` in the registry.
2. Notifies all connected callers with a `TRANSPORT_ERROR`.
3. Optionally restarts the module (configurable: restart policy with
   exponential backoff).
4. On restart, the module goes through the full lifecycle again
   (load -> init -> ready).

### 10.2 Graceful Shutdown

On runtime shutdown:

1. All modules receive `_destroy()` in reverse dependency order.
2. Socket connections are closed.
3. Module host processes are sent `SIGTERM`, then `SIGKILL` after a timeout.

If a socket-hosted module fails during startup before it reaches ready state,
the same cleanup rule applies to the partially started host process.
The runtime MUST NOT leave failed startup children running as unregistered
modules.

---

## 11. UI Bridge (UI Modules)

UI bridge details are out of scope for this specification.
They belong in downstream specifications or framework-specific documents.

The only runtime-level requirement is that any such bridge preserve the
canonical module contract defined by LOGOS-MODULE-INTERFACE and the execution
semantics defined by this runtime specification.

---

## 12. Large Payload Boundary

The runtime lifecycle model does not define a generic streaming or
chunked-transfer facility.
Ordinary module calls may be routed directly or through a transport binding,
but the runtime does not make request, response, or event payloads unbounded.

Message framing and message-size limits are transport-binding concerns.
For stream transports, they are defined by LOGOS-MODULE-TRANSPORT.

Module interfaces that need large data transfer in this version should model
that explicitly in their schema, for example with:

- filesystem paths for co-located modules
- external references (URLs, CIDs) that the caller can fetch separately
- multiple smaller requests if the data can be chunked at the
  application level

Future specifications may define generic streaming or large-object transfer
profiles.
That transport extension belongs primarily in LOGOS-MODULE-TRANSPORT, while
any schema-level conventions for chunked methods or stream references belong
in LOGOS-MODULE-INTERFACE.

---

## Appendix A. Implementation Notes (Informative)

A generic module host that receives LOGOS-MODULE-TRANSPORT requests still has
to invoke schema-derived per-method C functions whose C signatures vary by
method.
Those functions take an opaque `logos_call_context_t*` as their first
argument, supplied by the runtime or module host.

This specification does not require one implementation strategy.

Known implementation strategies include:

- deriving calls at runtime with a foreign-function interface such as `libffi`
  from the module schema and LOGOS-MODULE-INTERFACE C mapping, including the
  call-context pointer;
- generating per-module host adapter code that decodes transport requests and
  calls the native C API directly;
- generating a uniform dispatch table, vtable, or internal host-call ABI
  alongside the ergonomic per-method C API.

The preferred implementation strategy is the foreign-function-interface model,
because it lets a generic runtime host call the ordinary native C API at
runtime without making a generated dispatch function part of the portable
module ABI.
The dispatch-table or vtable strategy is allowed in this revision, but it is
not the preferred strategy because it adds a second invocation surface beside
the ordinary native C API.

### A.1 Fixed Static Applications

The Logos module architecture also supports fully static application packaging.
In this packaging style, the module set is curated at build or packaging time,
and runtime discovery MAY be reduced or omitted by the selected implementation.

Both patterns below still use the same mandatory callee-side C symbols defined
by LOGOS-MODULE-INTERFACE.
Neither pattern defines a second module API.

**Generated runtime facade library.**
A generated runtime facade library is the lowest-friction static packaging form.
The application driver links one generated library and includes one generated
facade header.

The facade links the curated modules and MAY include or link the runtime
components needed by the generated caller-side APIs.
The application driver does not include individual module headers, perform
module binding, or manage module lifecycle ordering directly.

A generated runtime facade library differs from ordinary direct C embedding.
In ordinary direct C embedding, the application includes module headers and
calls each module API itself.
The facade instead consolidates the curated module set behind one app-facing API.

If the facade includes the relevant runtime components, it can provide Logos
runtime behavior such as lifecycle management, callback wiring, event delivery,
outbound module calls, and policy checks.
A facade that omits those runtime components is only a generated direct-call
wrapper and does not provide the omitted runtime behavior.

This pattern is useful when the module set is fixed and the application driver
should remain small.

**Fixed embedded-runtime app.**
A fixed embedded-runtime app links the runtime library and the curated modules
directly.
The application uses the runtime API explicitly.
The application or generated startup glue makes static direct-mode bindings
available to the runtime before `logos_runtime_start()`.

Compared with a generated runtime facade library, this pattern leaves runtime
setup visible to the application.
The application can choose the registered module set, initialization order,
policy configuration, test bindings, and other runtime options exposed by the
runtime API.
It still avoids dynamic loading and transport serialization for curated modules.

Build-time or package-time schema checks MAY replace runtime discovery or schema
negotiation where the module set and versions are fixed.

---

## References

### Normative

- LOGOS-MODULE-INTERFACE -- Module interface definition specification.
- LOGOS-MODULE-TRANSPORT -- Socket protocol specification.

### Informative

- logos-liblogos -- Current runtime implementation (Qt-based).
  https://github.com/logos-co/logos-liblogos

---

## Copyright

Copyright and related rights waived via
[CC0](https://creativecommons.org/publicdomain/zero/1.0/).
