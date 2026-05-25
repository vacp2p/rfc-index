# ANALYSIS-BLOCK-TIMES-BLEND-NETWORK

| Field | Value |
| --- | --- |
| Name | [Analysis] Block Times & Blend Network |
| Slug | 186 |
| Status | raw |
| Category | Informational |
| Editor | David Rusu <davidrusu@logos.co> |
| Contributors | Filip Dimitrijevic <filip@logos.co> |

<!-- timeline:start -->

## Timeline

- **2026-05-22** — [`e8cedab`](https://github.com/logos-co/logos-lips/blob/e8cedab986dd17a9ff7bc718398b7162c2ab0d89/docs/blockchain/raw/analysis-block-times-blend-network.md) — fix(blockchain): re-import 25 Notion-only spec bodies with proper markdown formatting
- **2026-05-22** — [`4c38737`](https://github.com/logos-co/logos-lips/blob/4c38737840346f1d3ba899ecab61c255e5c88f93/docs/blockchain/raw/analysis-block-times-blend-network.md) — chore(blockchain): import 25 Notion-only specs as scaffold files (PR #2A)

<!-- timeline:end -->

# Revision History

| Version | Changes | Date |
| --- | --- | --- |
| 1.0.0 | Initial revision. | 2025-08-20 |

# Introduction

We are interested in finalizing the Cryptarchia and Blend Network parameters. There are some competing requirements here: the Blend Network would like to have longer block times in order to provide better privacy, while Cryptarchia wants shorter block times in order to provide faster finality.

We need to find the right balance that would give us good enough privacy while not sacrificing finality times too much.

# Overview

## Adversary Model

The analysis centres on the block-witholding attack where an adversary does not participate in the main chain, instead building a secret side-chain and releasing it on the network in an attempt to trigger the honest chain to reorg.

![](https://nomos-tech.notion.site/image/attachment%3Af50d7db7-f587-444d-83b5-588152783c58%3Ae2262146-b431-492f-ba37-2d08baa44e98.png?table=block&id=1fd261aa-09df-81e2-8f1d-d581af37ee93&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&width=1410&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

![](https://nomos-tech.notion.site/image/attachment%3A7fb66e20-6f1c-4d35-b5e6-12da6a9061d7%3AScreenshot_2025-05-19_at_4.40.22_AM.png?table=block&id=1fd261aa-09df-8118-85ea-e794d12e25ce&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&width=1410&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

![](https://nomos-tech.notion.site/image/attachment%3A048f2b8b-2146-4be0-90e9-f74a948bdb7a%3A867b795c-9209-4f0b-a01f-4d1387830415.png?table=block&id=1fd261aa-09df-8147-aff8-ecbf9a4043cb&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&width=1410&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

![](https://nomos-tech.notion.site/image/attachment%3A294162a0-cfb5-401e-9514-7fbaec455d58%3A5aaeedc4-0bad-4744-abcd-ae0c0d803795.png?table=block&id=1fd261aa-09df-816c-ae5c-cac90e8d3251&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&width=1410&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

![](https://nomos-tech.notion.site/image/attachment%3Acb624b0c-091b-4d17-94db-16680276e3af%3A16cbb592-1e66-4c21-be5a-70f6fa088ecd.png?table=block&id=1fd261aa-09df-813a-b804-e77dc026f5fc&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&width=1410&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

### Network Model

![](https://nomos-tech.notion.site/image/attachment%3Adeb5394d-68cd-4cb4-8705-46cd2dd56420%3AScreenshot_2025-05-19_at_6.38.40_AM.png?table=block&id=1fd261aa-09df-8109-a514-d47694bceba4&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&width=830&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

```
blend_network = NetworkParams(
    broadcast_delay_mean=0.5, # seconds
    pol_proof_time=1, # 1 second PoL delay
    blending_delay=3, # seconds spent in each Blend node
    desimenation_delay_mean=0.5, # seconds to disseminate message within Blend
    blend_hops=3, # hops within Blend
)
no_blend_net = replace(blend_net, blend_hops=0)
```

The block delay distribution from the network model looks like this:

![](https://nomos-tech.notion.site/image/attachment%3A5c98069f-a0df-4a5d-af27-eee28d14504f%3Aimage.png?table=block&id=1fd261aa-09df-81cf-91be-ea205ebe1ff7&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&width=1090&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

# Choosing a Block Time

![](https://nomos-tech.notion.site/image/attachment%3A3816f738-2d8e-4d51-a4b6-4303172a8c46%3Aimage.png?table=block&id=1fd261aa-09df-810c-8387-c09c205bbfba&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&width=1520&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

```
PATHS = 5
target_block_num = 20000
np.random.seed(0)
stake = np.random.pareto(10, 1000)
network = blend_net
sim_params = Params(
    SLOTS=0,
    f=0.05,
    adversary_control = 0.30,
    honest_stake = stake
)
np.random.seed(1)
sims = [Sim(
    params=replace(
        sim_params,
        SLOTS=int(target_block_num * block_time),
        f=1/block_time
    ),
    network=network
) for block_time in np.array([15, 30, 60, 120]).repeat(PATHS)]
```

# Choosing Blend Parameters

There are two parameters that are of concern here: Number of Hops and the Blending Delay.

The number of hops tells us how many times the block proposal needs to be processed by the network before the proposal is broadcast to the wider network.

The Blending delay tells us the maximum time each message is processed at each hop.

## Number of Hops

![](https://nomos-tech.notion.site/image/attachment%3A4d9bb5c8-718e-46df-a576-8bab449af7d2%3Aimage.png?table=block&id=1fd261aa-09df-8145-8d13-e9397ee09326&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&width=630&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

![](https://nomos-tech.notion.site/image/attachment%3Af4b6a428-282d-45e8-9af3-228b823ecbdd%3Aimage.png?table=block&id=1fd261aa-09df-81d2-8816-f6a1748e6cb0&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&width=630&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

![](https://nomos-tech.notion.site/image/attachment%3A78d1e6ac-f170-4460-8caa-208471592756%3Aimage.png?table=block&id=1fd261aa-09df-81f8-9df6-cf80bcfbd8e8&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&width=530&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

![](https://nomos-tech.notion.site/image/attachment%3Ad2bcd781-e055-4c05-a94b-285c263ca001%3Aimage.png?table=block&id=1fd261aa-09df-815b-a1da-c5c6d24a6c97&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&width=1770&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

```
PATHS = 3
target_block_num = 20000
np.random.seed(0)
stake = np.random.pareto(10, 1000)
block_time = 30
sim_params = Params(
    SLOTS=int(target_block_num * block_time),
    f=1/block_time,
    adversary_control = 0.30,
    honest_stake = stake
)
np.random.seed(1)
sims = [Sim(
    params=sim_params,
    network=replace(blend_net, blend_hops=hops)
) for hops in np.array([1, 2, 3]).repeat(PATHS)]
```

From these plots we can see that going above 3 hops begins to induce too many reorgs.

## Blending Delay

![](https://nomos-tech.notion.site/image/attachment%3Ab6859ce4-1ac0-4cb2-aa79-c04a742b84f5%3Aimage.png?table=block&id=1fd261aa-09df-8153-bb9d-daab1e63dfb5&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&width=630&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

![](https://nomos-tech.notion.site/image/attachment%3A1f240390-37fb-491d-a479-6a05e0c0a240%3Aimage.png?table=block&id=1fd261aa-09df-81c6-976d-f7ff7c0fe1ae&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&width=630&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

![](https://nomos-tech.notion.site/image/attachment%3A21de600b-f278-48a4-b482-3acb9cd17f50%3Aimage.png?table=block&id=1fd261aa-09df-8165-8943-c5857cbbf8cb&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&width=530&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

![](https://nomos-tech.notion.site/image/attachment%3Ab2237f34-9d21-492c-bff1-6912b840d355%3Aimage.png?table=block&id=1fd261aa-09df-813e-9794-fa67940ebeeb&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&width=1520&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

```
PATHS = 3
target_block_num = 20000
np.random.seed(0)
stake = np.random.pareto(10, 1000)
block_time = 30
sim_params = Params(
    SLOTS=int(target_block_num * block_time),
    f=1/block_time,
    adversary_control = 0.30,
    honest_stake = stake
)
np.random.seed(1)
sims = [Sim(
    params=sim_params,
    network=replace(blend_net, blending_delay=delay)
) for delay in np.array([3, 5, 10]).repeat(PATHS)]
```

A blending delay above 3 seconds induces too many reorgs.

## Impact of Combinations of Hops and Delays

Checking parameters in combinations shows that again, going above 3 hops or above a 3 second delay leads to divergence from the Cardano baseline.

![](https://nomos-tech.notion.site/image/attachment%3Ad0b22847-d2aa-464d-8f68-7d8167772376%3Aimage.png?table=block&id=1fd261aa-09df-81e8-8875-c160935c1596&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&width=840&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

![](https://nomos-tech.notion.site/image/attachment%3A074cd8f9-eaa0-4dc7-9f7e-ff2028850a09%3Aimage.png?table=block&id=1fd261aa-09df-81b1-a38c-fa24f63452c7&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&width=840&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

![](https://nomos-tech.notion.site/image/attachment%3A24192bfc-fd2a-42d5-9536-ccbdc5189b30%3Aimage.png?table=block&id=1fd261aa-09df-8149-b2c6-de140ee6532b&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&width=840&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

# Powerful Adversaries

With 3 hops and 3 second delays, it’s interesting too look at how the network would behave under different strength adversaries.

## 10% Adversary

![](https://nomos-tech.notion.site/image/attachment%3A797506c9-a057-4e8c-a44c-31e2661327d6%3Aimage.png?table=block&id=214261aa-09df-8035-8a0a-eee05f2d5daa&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&width=640&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

![](https://nomos-tech.notion.site/image/attachment%3A0cdadba2-9733-43ba-a557-6f2c2d6a7442%3Aimage.png?table=block&id=214261aa-09df-8083-a890-fc767d191464&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&width=640&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

![](https://nomos-tech.notion.site/image/attachment%3Aa5eee329-f622-4903-abad-b9bad4ae2e9a%3Aimage.png?table=block&id=213261aa-09df-80c6-beb3-e8479660853f&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&width=640&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

![](https://nomos-tech.notion.site/image/attachment%3A098cc819-6139-47f1-ab3c-12ed3d1da6f3%3Aimage.png?table=block&id=213261aa-09df-8091-b6a1-cbfa584c6d7d&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&width=640&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

<details>
<summary>Params</summary>

```
PATHS = 3
target_block_num = 20000
np.random.seed(0)
stake = np.random.pareto(10, 1000)
network = blend_net
sim_params = Params(
    SLOTS=0,
    f=0.05,
    adversary_control = 0.10,
    honest_stake = stake
)
np.random.seed(1)
sims = [Sim(
    params=replace(
        sim_params,
        SLOTS=int(target_block_num * block_time),
        f=1/block_time
    ),
    network=network
) for block_time in np.array([30]).repeat(PATHS)]
```

</details>

## 30% Adversary

![](https://nomos-tech.notion.site/image/attachment%3A8eb355df-ba86-4a05-bc64-2af6557f331b%3Aimage.png?table=block&id=214261aa-09df-8016-9b10-f3ba2db6b8fa&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&width=640&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

![](https://nomos-tech.notion.site/image/attachment%3Ace7b555a-987a-47bd-881b-fb5bdc3ecd53%3Aimage.png?table=block&id=214261aa-09df-8008-a7a6-edc747a1e614&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&width=640&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

![](https://nomos-tech.notion.site/image/attachment%3A80eff31a-d63f-4219-ada9-747e08a7e80b%3Aimage.png?table=block&id=213261aa-09df-80be-8ebb-c34b70e127f6&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&width=640&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

![](https://nomos-tech.notion.site/image/attachment%3A9720f424-dd93-4384-a2a2-d1f465839326%3Aimage.png?table=block&id=213261aa-09df-80c9-be0b-d7dad0797dc1&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&width=640&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

### 35s block times, 3s blending delay

![](https://nomos-tech.notion.site/image/attachment%3A346c1998-5de8-441a-9adc-bef9b43d1f5f%3Aimage.png?table=block&id=214261aa-09df-80ab-a2dc-e3ebd7128d65&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&width=640&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

![](https://nomos-tech.notion.site/image/attachment%3A482dcc2a-a6d0-423f-870d-129168ccea8c%3Aimage.png?table=block&id=214261aa-09df-8084-a558-d8dbda3cc177&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&width=630&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

<details>
<summary>Params</summary>

```
PATHS = 1
target_block_num = 200000
np.random.seed(0)
stake = np.random.pareto(10, 100)
network = blend_net
sim_params = Params(
    SLOTS=0,
    f=0.05,
    adversary_control = 0.3,
    honest_stake = stake
)
np.random.seed(1)
sims = [Sim(
    params=replace(
        sim_params,
        SLOTS=int(target_block_num * block_time),
        f=1/block_time
    ),
    network=network
) for block_time in np.array([30]).repeat(PATHS)]
for i, sim in enumerate(sims):
print(f"simulating {i+1}/{len(sims)}")
    sim.run(seed=i)
print("finished simulation, starting analysis")
advs = [sim.adverserial_analysis() for sim in sims]
print("cardano parameters")
cardano_block_time = 20
cardano_sims = [Sim(
    params=replace(
        sim_params,
        SLOTS=int(target_block_num * cardano_block_time),
        f=1/cardano_block_time,
),
    network=replace(network, blend_hops=0)
) for _ in range(PATHS)]
for i, sim in enumerate(cardano_sims):
print(f"simulating {i+1}/{len(cardano_sims)}")
    sim.run(seed=i)

cardano_advs = [sim.adverserial_analysis() for sim in cardano_sims]
# -------

PATHS = 3
target_block_num = 20000
np.random.seed(0)
stake = np.random.pareto(10, 1000)
network = blend_net
sim_params = Params(
    SLOTS=0,
    f=0.05,
    adversary_control = 0.30,
    honest_stake = stake
)
np.random.seed(1)
sims = [Sim(
    params=replace(
        sim_params,
        SLOTS=int(target_block_num * block_time),
        f=1/block_time
    ),
    network=network
) for block_time in np.array([30]).repeat(PATHS)]
```

</details>

## 40% Adversary

![](https://nomos-tech.notion.site/image/attachment%3Aca3dc9b9-a9a7-4723-a1b0-6808443a6089%3Aimage.png?table=block&id=214261aa-09df-801a-b1c8-da2b531ea6c1&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&width=630&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

![](https://nomos-tech.notion.site/image/attachment%3A21b33212-d92b-4926-bb0e-62525fb60ebf%3Aimage.png?table=block&id=214261aa-09df-80dd-9cae-ee3b0c528a22&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&width=630&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

![](https://nomos-tech.notion.site/image/attachment%3A8cc23f87-416a-4e71-86ce-ce5154ce3a23%3Aimage.png?table=block&id=213261aa-09df-80dc-bfbc-cb89b50c607d&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&width=630&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

![](https://nomos-tech.notion.site/image/attachment%3Af8098561-c99f-4927-a722-41e95b8d460a%3Aimage.png?table=block&id=213261aa-09df-80c2-8a7f-e8229fa3d7b7&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&width=640&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

<details>
<summary>Params</summary>

```
PATHS = 5
target_block_num = 40000
np.random.seed(0)
stake = np.random.pareto(10, 1000)
network = blend_net
sim_params = Params(
    SLOTS=0,
    f=0.05,
    adversary_control = 0.40,
    honest_stake = stake
)
np.random.seed(1)
sims = [Sim(
    params=replace(
        sim_params,
        SLOTS=int(target_block_num * block_time),
        f=1/block_time
    ),
    network=network
) for block_time in np.array([30]).repeat(PATHS)]
```

</details>

## 45% Adversary

![](https://nomos-tech.notion.site/image/attachment%3A8377a72b-07e4-4f16-9f2f-f67cbd26de0d%3Aimage.png?table=block&id=214261aa-09df-806f-991f-e3457a675ea1&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&width=630&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

![](https://nomos-tech.notion.site/image/attachment%3Ab108d508-056a-4952-ae57-5b209e39bc7f%3Aimage.png?table=block&id=214261aa-09df-8024-8d98-fc16afb41f8f&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&width=630&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

![](https://nomos-tech.notion.site/image/attachment%3Af507a84a-4c1f-4d40-9cf0-4c7b9a0eb51c%3Aimage.png?table=block&id=213261aa-09df-8071-9a1d-cacfe2018b90&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&width=640&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

![](https://nomos-tech.notion.site/image/attachment%3A7a99dfa2-34f1-42a6-841b-97b819282e70%3Aimage.png?table=block&id=213261aa-09df-80d4-9ff7-f8770cf34b73&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&width=630&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

<details>
<summary>Params</summary>

```
PATHS = 5
target_block_num = 40000
np.random.seed(0)
stake = np.random.pareto(10, 1000)
network = blend_net
sim_params = Params(
    SLOTS=0,
    f=0.05,
    adversary_control = 0.45,
    honest_stake = stake
)
np.random.seed(1)
sims = [Sim(
    params=replace(
        sim_params,
        SLOTS=int(target_block_num * block_time),
        f=1/block_time
    ),
    network=network
) for block_time in np.array([30]).repeat(PATHS)]
```

</details>

## 49% Adversary

![](https://nomos-tech.notion.site/image/attachment%3Ad6a333c7-fa70-4f20-b548-243ccc4d6073%3Aimage.png?table=block&id=214261aa-09df-802e-a1aa-d86cd64b55d5&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&width=630&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

![](https://nomos-tech.notion.site/image/attachment%3A0e681563-8d3b-4fad-8c28-86bc5cbe563a%3Aimage.png?table=block&id=214261aa-09df-80ab-a193-cbbd694ab243&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&width=630&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

![](https://nomos-tech.notion.site/image/attachment%3A9d074e98-257b-4690-8715-eac7ac50fc3c%3Aimage.png?table=block&id=214261aa-09df-80bc-b95d-ebdd0ebfbe9c&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&width=630&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

![](https://nomos-tech.notion.site/image/attachment%3Af32b7c42-a957-4438-ad4e-5c626ce0f1f1%3Aimage.png?table=block&id=214261aa-09df-800c-9fda-f1ffd446277c&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&width=630&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

<details>
<summary>Params</summary>

```
PATHS = 5
target_block_num = 30000
np.random.seed(0)
stake = np.random.pareto(10, 1000)
network = blend_net
sim_params = Params(
    SLOTS=0,
    f=0.05,
    adversary_control = 0.49,
    honest_stake = stake
)
np.random.seed(1)
sims = [Sim(
    params=replace(
        sim_params,
        SLOTS=int(target_block_num * block_time),
        f=1/block_time
    ),
    network=network
) for block_time in np.array([30]).repeat(PATHS)]
```

</details>

# Conclusion

Our conclusion is that 30s block times, 3 blend hops, 2s blending delay are safe and we propose we use this parameter set for Nomos.

# Annex

## Exploring Analytical Results from Praos

Praos provides the following theorem about the probability of violating the common prefix property:

![](https://nomos-tech.notion.site/image/attachment%3A205256da-b335-4d2b-a5ea-21d913c32220%3AScreenshot_2025-06-12_at_12.17.20_AM.png?table=block&id=210261aa-09df-80e6-a8ff-ce174779e49c&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&width=1410&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

In addition to simulations, we could try to use this analytical results to determine the impact of changing block times and network assumptions.

### Theorem Condition

First we must satisfy the condition $\alpha (1-f)^{\Delta + 1} \ge \frac{1+\epsilon}{2}$ where

- $\alpha$ is the stake held by honest parties
- $f$ is the active slot coefficient
- $\Delta$ is the max network delay
- $\epsilon >0$ is the advantage of the honest network over the adversarial network

We want to understand for a given parameter set, what is the required honest stake $\alpha$ to satisfy the safety condition:

$$
\begin{align}
\alpha (1-f)^{\Delta + 1} &\ge \frac{1+\epsilon}{2} \\

\alpha &\ge \frac{1 + \epsilon}{2(1-f)^{\Delta + 1}}
\end{align}
$$

We can then look at the minimum $\alpha$ that satisfies this condition for Cardano and Nomos.

![](https://nomos-tech.notion.site/image/attachment%3A8c60a505-aabd-4f2f-90bf-52c39e199f07%3Aimage.png?table=block&id=210261aa-09df-805d-a8eb-d3d3cc364eac&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&width=640&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

![](https://nomos-tech.notion.site/image/attachment%3A22cdc3e9-301c-4ed8-9b42-75f831cf3981%3Aimage.png?table=block&id=210261aa-09df-805b-8d27-ecc458607bef&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&width=630&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

Surprisingly, at at 5s max network delay, we are already requiring ~70% of stake to be honest in Cardano.

On Nomos, based on the network modelling we had done, we had a ~14s max delay. This would require 83% of the network to be honest in order to satisfy this condition.

![](https://nomos-tech.notion.site/image/attachment%3A5c98069f-a0df-4a5d-af27-eee28d14504f%3Aimage.png?table=block&id=210261aa-09df-80a5-95ce-d050013cc62a&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&width=470&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

If we change our blending delay to 2s, then we have a ~11s max delay. This would require 75% of the network to be honest in order to satisfy this condition.

![](https://nomos-tech.notion.site/image/attachment%3A8da09c51-a1d5-4933-bf98-b891785c0db7%3Aimage.png?table=block&id=214261aa-09df-809c-bfca-fc5d53ca46a5&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&width=470&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

### Probability of Violating Common Prefix

The main result of the theorem states that the probability of violating common prefix is bounded above by $\exp(\ln(R)+\Delta - \Omega(k))$, where $\Omega(k)$ is asymptotic notation reflecting a term that grows at least as fast as $k$.

We can ask the question “how does the probability change if we change our parameters from Cardano’s to Nomos’?”

We don’t know the $\Omega(k)$ term, but we can get the relative change by dividing the Cardano probability by the Nomos probability, and cancel out the $\Omega(k)$ term:

$$
\begin{align}

\frac{\exp(ln(R) + \Delta_{cardano} - \Omega(k))}{\exp(ln(R) + \Delta_{nomos} - \Omega(k))} &= \frac{Re^{\Delta_{cardano}-\Omega(k)}}{Re^{\Delta_{nomos}-\Omega(k)}} \\
&= e^{\Delta_{cardano} - \Delta_{nomos}}
\end{align}
$$

So, we have the ratio $\frac{P(\text{violate common prefix in cardano})}{P(\text{violate common prefix in nomos}}=\exp(\Delta_{cardano} - \Delta_{nomos})$. Plotting this for $\Delta_{cardano}=5$ against different network delays in Nomos gives this plot:

![](https://nomos-tech.notion.site/image/attachment%3Aed983ead-3ec9-41f5-b834-9bf6d3661cdf%3Aimage.png?table=block&id=210261aa-09df-8099-97a6-e04c50aa92af&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&width=1230&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

My interpretation of this result is that this probability $\exp(\ln(R)+\Delta - \Omega(k))$ is a very loose upper bound. e.g. reducing network delay by 1s leads to a ~2.7x lower probability, and adding 1 second of delay leads again to a 2.7x higher probability, it’s too sensitive to make useful interpretations.

