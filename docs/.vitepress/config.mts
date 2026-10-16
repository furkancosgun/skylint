import { defineConfig } from 'vitepress';

export default defineConfig({
  title: 'Skylint',
  description: 'Enterprise Clean ABAP & Cloud ATC Linter Engine',
  base: process.env.VITEPRESS_BASE || '/',
  themeConfig: {
    logo: '/logo.svg',
    nav: [
      { text: 'Guide', link: '/guide/getting-started' },
      { text: 'Rules', link: '/rules/' },
      { text: 'GitHub', link: 'https://github.com/furkancosgun/skylint' },
    ],
    sidebar: {
      '/guide/': [
        {
          text: 'Introduction',
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
        "text": "merge-nested-ifs",
        "link": "/rules/merge-nested-ifs"
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
        "text": "prefer-raise-new",
        "link": "/rules/prefer-raise-new"
      },
      {
        "text": "prefer-xsdbool",
        "link": "/rules/prefer-xsdbool"
      },
      {
        "text": "require-fully-typed",
        "link": "/rules/require-fully-typed"
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
        "text": "clean-constructor",
        "link": "/rules/clean-constructor"
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
        "text": "test-method-naming",
        "link": "/rules/test-method-naming"
      },
      {
        "text": "prefer-final-method",
        "link": "/rules/prefer-final-method"
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
        "text": "prefer-early-continue",
        "link": "/rules/prefer-early-continue"
      },
      {
        "text": "prefer-early-return",
        "link": "/rules/prefer-early-return"
      },
      {
        "text": "require-decl-order",
        "link": "/rules/require-decl-order"
      },
      {
        "text": "no-param-escape",
        "link": "/rules/no-param-escape"
      },
      {
        "text": "prefer-case",
        "link": "/rules/prefer-case"
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
        "text": "no-exporting",
        "link": "/rules/no-exporting"
      },
      {
        "text": "no-chained-assignment",
        "link": "/rules/no-chained-assignment"
      },
      {
        "text": "no-chained-decl",
        "link": "/rules/no-chained-decl"
      },
      {
        "text": "no-boolean-comparison",
        "link": "/rules/no-boolean-comparison"
      },
      {
        "text": "no-check-in-loop",
        "link": "/rules/no-check-in-loop"
      },
      {
        "text": "no-empty-block",
        "link": "/rules/no-empty-block"
      },
      {
        "text": "no-empty-catch",
        "link": "/rules/no-empty-catch"
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
        "text": "no-receiving",
        "link": "/rules/no-receiving"
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
        "text": "no-scope-leak",
        "link": "/rules/no-scope-leak"
      },
      {
        "text": "no-self-assignment",
        "link": "/rules/no-self-assignment"
      },
      {
        "text": "no-single-param-name",
        "link": "/rules/no-single-param-name"
      },
      {
        "text": "no-try-without-catch",
        "link": "/rules/no-try-without-catch"
      },
      {
        "text": "no-sy-modify",
        "link": "/rules/no-sy-modify"
      },
      {
        "text": "no-raise-shortdump",
        "link": "/rules/no-raise-shortdump"
      },
      {
        "text": "no-magic-numbers",
        "link": "/rules/no-magic-numbers"
      },
      {
        "text": "no-obsolete-loop-control",
        "link": "/rules/no-obsolete-loop-control"
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
        "text": "no-form-routines",
        "link": "/rules/no-form-routines"
      },
      {
        "text": "no-unused-variables",
        "link": "/rules/no-unused-variables"
      },
      {
        "text": "no-inline-length",
        "link": "/rules/no-inline-length"
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
        "text": "require-order-by",
        "link": "/rules/require-order-by"
      },
      {
        "text": "require-transporting",
        "link": "/rules/require-transporting"
      }
    ]
  },
  {
    "text": "Security & Robustness",
    "collapsed": false,
    "items": [
      {
        "text": "no-dangerous-dynamic",
        "link": "/rules/no-dangerous-dynamic"
      },
      {
        "text": "require-auth-check",
        "link": "/rules/require-auth-check"
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
        "text": "require-subrc-check",
        "link": "/rules/require-subrc-check"
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
        "text": "no-raw-dynamic-sql",
        "link": "/rules/no-raw-dynamic-sql"
      },
      {
        "text": "no-production-assert",
        "link": "/rules/no-production-assert"
      },
      {
        "text": "no-forbidden-statements",
        "link": "/rules/no-forbidden-statements"
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
