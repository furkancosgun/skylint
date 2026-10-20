import { defineConfig } from 'vitepress';

export default defineConfig({
  title: 'Skylint',
  description: 'Enterprise Clean ABAP & Cloud ATC Linter Engine',
  base: process.env.VITEPRESS_BASE || '/',
  cleanUrls: true,
  lastUpdated: true,
  sitemap: {
    hostname: 'https://furkancosgun.github.io/skylint',
  },
  head: [
    ['link', { rel: 'icon', type: 'image/svg+xml', href: '/logo.svg' }],
    ['meta', { name: 'robots', content: 'index, follow' }],
    ['meta', { property: 'og:type', content: 'website' }],
    ['meta', { property: 'og:title', content: 'Skylint - Enterprise Clean ABAP & Cloud ATC Linter' }],
    ['meta', { property: 'og:description', content: 'Enterprise Clean ABAP & Cloud ATC Linter Engine' }],
    ['meta', { property: 'og:image', content: 'https://furkancosgun.github.io/skylint/logo.svg' }],
  ],
  themeConfig: {
    logo: '/logo.svg',
    nav: [
      { text: 'Guide', link: '/guide/getting-started' },
      { text: 'Rules (95)', link: '/rules/' },
      { text: 'GitHub', link: 'https://github.com/furkancosgun/skylint' },
    ],
    sidebar: {
      '/guide/': [
        {
          text: 'Architecture & Guides',
          items: [
            { text: 'Getting Started', link: '/guide/getting-started' },
            { text: 'Configuration (skylint.yaml)', link: '/guide/configuration' },
            { text: 'SAP ATC Integration', link: '/guide/atc-integration' },
            { text: 'Suppressions & Pragmas', link: '/guide/suppressions' },
          ],
        },
      ],
      '/rules/': [
        { text: 'All Rules Overview', link: '/rules/' },
        ...[
  {
    "text": "Clean ABAP & Modern Syntax",
    "collapsed": false,
    "items": [
      {
        "text": "prefer-lines",
        "link": "/rules/prefer-lines"
      },
      {
        "text": "prefer-is-not",
        "link": "/rules/prefer-is-not"
      },
      {
        "text": "prefer-string-template",
        "link": "/rules/prefer-string-template"
      },
      {
        "text": "prefer-line-exists",
        "link": "/rules/prefer-line-exists"
      },
      {
        "text": "prefer-return",
        "link": "/rules/prefer-return"
      },
      {
        "text": "prefer-merged-ifs",
        "link": "/rules/prefer-merged-ifs"
      },
      {
        "text": "prefer-symbol-operators",
        "link": "/rules/prefer-symbol-operators"
      },
      {
        "text": "prefer-new-operator",
        "link": "/rules/prefer-new-operator"
      },
      {
        "text": "prefer-xsdbool",
        "link": "/rules/prefer-xsdbool"
      },
      {
        "text": "prefer-fully-typed",
        "link": "/rules/prefer-fully-typed"
      },
      {
        "text": "prefer-corresponding",
        "link": "/rules/prefer-corresponding"
      },
      {
        "text": "prefer-returning",
        "link": "/rules/prefer-returning"
      },
      {
        "text": "prefer-class-exceptions",
        "link": "/rules/prefer-class-exceptions"
      },
      {
        "text": "prefer-final-class",
        "link": "/rules/prefer-final-class"
      },
      {
        "text": "prefer-insert-into",
        "link": "/rules/prefer-insert-into"
      },
      {
        "text": "max-constructor-statements",
        "link": "/rules/max-constructor-statements"
      },
      {
        "text": "no-static-classes",
        "link": "/rules/no-static-classes"
      },
      {
        "text": "prefer-predicate-names",
        "link": "/rules/prefer-predicate-names"
      },
      {
        "text": "no-nested-try",
        "link": "/rules/no-nested-try"
      },
      {
        "text": "prefer-string-functions",
        "link": "/rules/prefer-string-functions"
      },
      {
        "text": "prefer-calc-assign-op",
        "link": "/rules/prefer-calc-assign-op"
      },
      {
        "text": "prefer-early-return",
        "link": "/rules/prefer-early-return"
      },
      {
        "text": "prefer-decl-order",
        "link": "/rules/prefer-decl-order"
      },
      {
        "text": "no-param-escape",
        "link": "/rules/no-param-escape"
      },
      {
        "text": "prefer-case",
        "link": "/rules/prefer-case"
      },
      {
        "text": "max-one-statement",
        "link": "/rules/max-one-statement"
      },
      {
        "text": "prefer-inline",
        "link": "/rules/prefer-inline"
      },
      {
        "text": "prefer-final-data",
        "link": "/rules/prefer-final-data"
      },
      {
        "text": "prefer-message-class",
        "link": "/rules/prefer-message-class"
      },
      {
        "text": "prefer-inline-cast",
        "link": "/rules/prefer-inline-cast"
      },
      {
        "text": "prefer-public-constructor",
        "link": "/rules/prefer-public-constructor"
      },
      {
        "text": "prefer-definitions-top",
        "link": "/rules/prefer-definitions-top"
      },
      {
        "text": "no-unnecessary-return",
        "link": "/rules/no-unnecessary-return"
      },
      {
        "text": "mix-returning",
        "link": "/rules/mix-returning"
      },
      {
        "text": "max-one-method-parameter-per-line",
        "link": "/rules/max-one-method-parameter-per-line"
      },
      {
        "text": "prefer-is-initial",
        "link": "/rules/prefer-is-initial"
      },
      {
        "text": "prefer-cast",
        "link": "/rules/prefer-cast"
      },
      {
        "text": "no-redundant-clear",
        "link": "/rules/no-redundant-clear"
      },
      {
        "text": "prefer-naming",
        "link": "/rules/prefer-naming"
      }
    ]
  },
  {
    "text": "Anti-Patterns & Bad Practices",
    "collapsed": false,
    "items": [
      {
        "text": "no-call-method",
        "link": "/rules/no-call-method"
      },
      {
        "text": "no-default-key",
        "link": "/rules/no-default-key"
      },
      {
        "text": "no-me-reference",
        "link": "/rules/no-me-reference"
      },
      {
        "text": "no-redundant-method-call",
        "link": "/rules/no-redundant-method-call"
      },
      {
        "text": "no-chained-statements",
        "link": "/rules/no-chained-statements"
      },
      {
        "text": "no-boolean-comparison",
        "link": "/rules/no-boolean-comparison"
      },
      {
        "text": "no-check-statement",
        "link": "/rules/no-check-statement"
      },
      {
        "text": "no-empty-block",
        "link": "/rules/no-empty-block"
      },
      {
        "text": "no-duplicate-conditions",
        "link": "/rules/no-duplicate-conditions"
      },
      {
        "text": "no-unreachable-code",
        "link": "/rules/no-unreachable-code"
      },
      {
        "text": "no-single-when",
        "link": "/rules/no-single-when"
      },
      {
        "text": "no-yoda-conditions",
        "link": "/rules/no-yoda-conditions"
      },
      {
        "text": "no-static-via-instance",
        "link": "/rules/no-static-via-instance"
      },
      {
        "text": "no-public-attributes",
        "link": "/rules/no-public-attributes"
      },
      {
        "text": "no-obsolete-statements",
        "link": "/rules/no-obsolete-statements"
      },
      {
        "text": "no-list-processing",
        "link": "/rules/no-list-processing"
      },
      {
        "text": "no-scope-leak",
        "link": "/rules/no-scope-leak"
      },
      {
        "text": "no-self-assignment",
        "link": "/rules/no-self-assignment"
      },
      {
        "text": "no-sy-modify",
        "link": "/rules/no-sy-modify"
      },
      {
        "text": "no-magic-numbers",
        "link": "/rules/no-magic-numbers"
      },
      {
        "text": "no-like-objects",
        "link": "/rules/no-like-objects"
      },
      {
        "text": "no-interface-data",
        "link": "/rules/no-interface-data"
      },
      {
        "text": "no-message-raising",
        "link": "/rules/no-message-raising"
      },
      {
        "text": "no-unused-variables",
        "link": "/rules/no-unused-variables"
      },
      {
        "text": "no-inline-length",
        "link": "/rules/no-inline-length"
      },
      {
        "text": "no-dash-in-names",
        "link": "/rules/no-dash-in-names"
      },
      {
        "text": "no-friends",
        "link": "/rules/no-friends"
      },
      {
        "text": "no-exception-overlap",
        "link": "/rules/no-exception-overlap"
      },
      {
        "text": "no-many-parentheses",
        "link": "/rules/no-many-parentheses"
      },
      {
        "text": "no-ignored-return-value",
        "link": "/rules/no-ignored-return-value"
      },
      {
        "text": "no-modify-loop-table",
        "link": "/rules/no-modify-loop-table"
      }
    ]
  },
  {
    "text": "Performance & Database",
    "collapsed": false,
    "items": [
      {
        "text": "no-db-in-loop",
        "link": "/rules/no-db-in-loop"
      },
      {
        "text": "no-empty-fae",
        "link": "/rules/no-empty-fae"
      },
      {
        "text": "no-select-star",
        "link": "/rules/no-select-star"
      },
      {
        "text": "prefer-order-by",
        "link": "/rules/prefer-order-by"
      },
      {
        "text": "prefer-transporting",
        "link": "/rules/prefer-transporting"
      },
      {
        "text": "prefer-pass-by-reference",
        "link": "/rules/prefer-pass-by-reference"
      }
    ]
  },
  {
    "text": "Security & Robustness",
    "collapsed": false,
    "items": [
      {
        "text": "no-dangerous-statements",
        "link": "/rules/no-dangerous-statements"
      },
      {
        "text": "prefer-auth-check",
        "link": "/rules/prefer-auth-check"
      },
      {
        "text": "no-catch-cx-root",
        "link": "/rules/no-catch-cx-root"
      },
      {
        "text": "no-raise-cx-sy",
        "link": "/rules/no-raise-cx-sy"
      },
      {
        "text": "prefer-subrc-check",
        "link": "/rules/prefer-subrc-check"
      },
      {
        "text": "no-client-specified",
        "link": "/rules/no-client-specified"
      },
      {
        "text": "no-commit-work",
        "link": "/rules/no-commit-work"
      },
      {
        "text": "no-rfc-error-handling",
        "link": "/rules/no-rfc-error-handling"
      },
      {
        "text": "no-modify-standard-tables",
        "link": "/rules/no-modify-standard-tables"
      },
      {
        "text": "no-dynamic-stuff",
        "link": "/rules/no-dynamic-stuff"
      },
      {
        "text": "no-hardcoded-env-checks",
        "link": "/rules/no-hardcoded-env-checks"
      }
    ]
  },
  {
    "text": "Metrics & Complexity Limits",
    "collapsed": false,
    "items": [
      {
        "text": "max-params",
        "link": "/rules/max-params"
      },
      {
        "text": "max-method-length",
        "link": "/rules/max-method-length"
      },
      {
        "text": "max-nesting-depth",
        "link": "/rules/max-nesting-depth"
      },
      {
        "text": "max-cyclomatic-complexity",
        "link": "/rules/max-cyclomatic-complexity"
      },
      {
        "text": "max-inheritance-depth",
        "link": "/rules/max-inheritance-depth"
      },
      {
        "text": "max-attributes",
        "link": "/rules/max-attributes"
      },
      {
        "text": "max-line-length",
        "link": "/rules/max-line-length"
      }
    ]
  }
]
      ],
    },
    search: {
      provider: 'local',
    },
    socialLinks: [
      { icon: 'github', link: 'https://github.com/furkancosgun/skylint' },
    ],
    footer: {
      message: 'Released under the MIT License.',
      copyright: 'Copyright © 2026 Skylint Contributors',
    },
  },
});
