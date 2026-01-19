// Based on https://github.com/status-im/status-web/blob/07e85e1d9eddc10be47e19c11a3bc5b6d3919c47/apps/status.app/.remarkrc.mjs
import remarkGfm from 'remark-gfm'
import remarkPresetLintConsistent from 'remark-preset-lint-consistent'
import remarkPresetLintRecommended from 'remark-preset-lint-recommended'

const disabledRecommended = new Set([
  'remark-lint:list-item-bullet-indent',
  'remark-lint:no-blockquote-without-marker',
  'remark-lint:no-undefined-references',
  'remark-lint:ordered-list-marker-style',
])

const disabledConsistent = new Set([
  'remark-lint:list-item-content-indent',
  'remark-lint:ordered-list-marker-style',
  'remark-lint:table-cell-padding',
])

const filteredRecommended = {
  ...remarkPresetLintRecommended,
  plugins: remarkPresetLintRecommended.plugins.filter((plugin) => {
    const entry = Array.isArray(plugin) ? plugin[0] : plugin
    const name = typeof entry === 'string' ? entry : entry?.name
    return !disabledRecommended.has(name)
  }),
}

const filteredConsistent = {
  ...remarkPresetLintConsistent,
  plugins: remarkPresetLintConsistent.plugins.filter((plugin) => {
    const entry = Array.isArray(plugin) ? plugin[0] : plugin
    const name = typeof entry === 'string' ? entry : entry?.name
    return !disabledConsistent.has(name)
  }),
}

/** @type {Array<import('unified').Plugin | import('unified').Preset>} */
const plugins = [
  remarkGfm,
  filteredConsistent,
  filteredRecommended,
  ['remark-lint-no-html', false],
  ['remark-lint-file-extension', false],
  ['remark-lint-no-literal-urls', false],
  ['remark-lint-no-paragraph-content-indent', false],
  ['remark-lint-maximum-heading-length', false],
  ['remark-lint-maximum-line-length', false],
  ['remark-lint-ordered-list-marker-value', false],
  ['remark-lint-unordered-list-marker-style', false],
  ['remark-lint-table-pipe-alignment', false],
  ['remark-lint-heading-style', false],
  ['remark-lint-first-heading-level', false],
  ['remark-lint-list-item-indent', false],
  ['remark-lint-list-item-spacing', false],
  ['remark-lint-heading-increment', false],
  ['remark-lint-no-duplicate-headings', false],
  ['remark-lint-no-duplicate-headings-in-section', false],
  ['remark-lint-no-emphasis-as-heading', false],
  ['remark-lint-emphasis-marker', false],
]

/** @type {import('unified').Preset} */
export default {
  settings: {
    emphasis: '_',
    bullet: '-',
    quote: '"',
    listItemIndent: 'one',
    rule: '-',
    incrementListMarker: false,
  },
  plugins,
}
