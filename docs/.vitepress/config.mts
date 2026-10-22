import { defineConfig } from 'vitepress';

const base = process.env.VITEPRESS_BASE || '/';

export default defineConfig({
  title: 'Skylint',
  titleTemplate: ':title | Enterprise Clean ABAP & Cloud ATC Linter',
  description: 'Enterprise Clean ABAP & Cloud ATC Linter Engine',
  base,
  cleanUrls: true,
  lastUpdated: true,
  sitemap: {
    hostname: 'https://skylint.org/',
  },
  vite: {
    build: {
      target: 'esnext',
    },
    esbuild: {
      target: 'esnext',
    },
  },
  head: [
    ['link', { rel: 'icon', type: 'image/svg+xml', href: `${base}logo.svg` }],
    ['link', { rel: 'sitemap', type: 'application/xml', title: 'Sitemap', href: 'https://skylint.org/sitemap.xml' }],
    ['meta', { name: 'robots', content: 'index, follow, max-image-preview:large, max-snippet:-1, max-video-preview:-1' }],
    ['meta', { name: 'google-site-verification', content: 'googlebe62f3b9b7abdd43' }],
    ['meta', { name: 'keywords', content: 'abap, clean abap, atc, sap, abap cloud, linter, static analysis, quickfix, btp, s4hana' }],
    ['meta', { property: 'og:type', content: 'website' }],
    ['meta', { property: 'og:image', content: 'https://skylint.org/og-image.png' }],
    ['meta', { property: 'og:image:width', content: '1200' }],
    ['meta', { property: 'og:image:height', content: '630' }],
    ['meta', { property: 'og:image:type', content: 'image/png' }],
    ['meta', { name: 'twitter:card', content: 'summary_large_image' }],
    ['meta', { name: 'twitter:image', content: 'https://skylint.org/og-image.png' }],
    ['style', {}, '@media (max-width: 768px) { .vp-doc { font-size: 15px; } }'],
  ],
  transformHead: ({ pageData, title, description }) => {
    if (pageData.isNotFound) {
      return [
        ['meta', { name: 'robots', content: 'noindex, nofollow' }],
      ];
    }

    const canonicalHostname = 'https://skylint.org';
    const cleanPath = pageData.relativePath
      .replace(/\.md$/, '')
      .replace(/(^|\/)index$/, '$1');
    const url = (canonicalHostname + '/' + cleanPath).replace(/\/+$/, '') + (cleanPath === '' || cleanPath.endsWith('/') ? '/' : '');

    const ogTitle = title === 'Skylint' ? 'Skylint - Enterprise Clean ABAP & Cloud ATC Linter' : (title || 'Skylint');
    const ogDescription = pageData.frontmatter?.description || description || 'Enterprise Clean ABAP & Cloud ATC Linter Engine';

    const tags = [
      ['link', { rel: 'canonical', href: url }],
      ['meta', { property: 'og:url', content: url }],
      ['meta', { property: 'og:title', content: ogTitle }],
      ['meta', { property: 'og:description', content: ogDescription }],
      ['meta', { property: 'og:updated_time', content: new Date().toISOString() }],
      ['meta', { property: 'article:modified_time', content: new Date().toISOString() }],
      ['meta', { name: 'description', content: ogDescription }],
      ['meta', { name: 'twitter:title', content: ogTitle }],
      ['meta', { name: 'twitter:description', content: ogDescription }],
    ];

    if (cleanPath === '') {
      tags.push([
        'script',
        { type: 'application/ld+json' },
        JSON.stringify({
          '@context': 'https://schema.org',
          '@type': 'SoftwareApplication',
          'name': 'Skylint',
          'applicationCategory': 'DeveloperApplication',
          'operatingSystem': 'SAP ABAP Cloud, Node.js',
          'description': 'Enterprise Clean ABAP & Cloud ATC Linter Engine with 104+ Native Rules',
          'url': 'https://skylint.org/',
          'license': 'https://github.com/furkancosgun/skylint/blob/main/LICENSE',
          'image': 'https://skylint.org/og-image.png',
          'offers': {
            '@type': 'Offer',
            'price': '0',
            'priceCurrency': 'USD',
          },
          'author': {
            '@type': 'Person',
            'name': 'Furkan COSGUN',
            'url': 'https://github.com/furkancosgun',
          },
        }),
      ]);
    }

    return tags;
  },
  themeConfig: {
    logo: { src: '/logo.svg', alt: 'Skylint Logo' },
    nav: [
      { text: 'Guide', link: '/guide/getting-started' },
      { text: 'Rules (104)', link: '/rules/' },
      { text: 'Variant Builder', link: '/variant-builder' },
      { text: 'GitHub', link: 'https://github.com/furkancosgun/skylint' },
    ],
    sidebar: {
      '/variant-builder': [],
      '/guide/': [
        {
          text: 'Architecture & Guides',
          items: [
            { text: 'Getting Started', link: '/guide/getting-started' },
            { text: 'Configuration (ATC Variants)', link: '/guide/configuration' },
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
        "text": "prefer-reduce",
        "link": "/rules/prefer-reduce"
      },
      {
        "text": "prefer-tab-expr",
        "link": "/rules/prefer-tab-expr"
      },
      {
        "text": "prefer-cond",
        "link": "/rules/prefer-cond"
      },
      {
        "text": "prefer-switch",
        "link": "/rules/prefer-switch"
      },
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
        "text": "prefer-predicate-names",
        "link": "/rules/prefer-predicate-names"
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
        "text": "prefer-naming",
        "link": "/rules/prefer-naming"
      },
      {
        "text": "bad-indent",
        "link": "/rules/bad-indent"
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
        "text": "no-magic-numbers",
        "link": "/rules/no-magic-numbers"
      },
      {
        "text": "no-like-objects",
        "link": "/rules/no-like-objects"
      },
      {
        "text": "no-static-classes",
        "link": "/rules/no-static-classes"
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
        "text": "no-nested-try",
        "link": "/rules/no-nested-try"
      },
      {
        "text": "no-unused-variables",
        "link": "/rules/no-unused-variables"
      },
      {
        "text": "no-param-escape",
        "link": "/rules/no-param-escape"
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
        "text": "no-unnecessary-return",
        "link": "/rules/no-unnecessary-return"
      },
      {
        "text": "mix-returning",
        "link": "/rules/mix-returning"
      },
      {
        "text": "method-overwrites-builtin",
        "link": "/rules/method-overwrites-builtin"
      },
      {
        "text": "no-ignored-return-value",
        "link": "/rules/no-ignored-return-value"
      },
      {
        "text": "no-redundant-clear",
        "link": "/rules/no-redundant-clear"
      },
      {
        "text": "expand-macros",
        "link": "/rules/expand-macros"
      },
      {
        "text": "no-dead-code",
        "link": "/rules/no-dead-code"
      },
      {
        "text": "keyword-name",
        "link": "/rules/keyword-name"
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
      },
      {
        "text": "no-modify-loop-table",
        "link": "/rules/no-modify-loop-table"
      }
    ]
  },
  {
    "text": "Security & Robustness",
    "collapsed": false,
    "items": [
      {
        "text": "no-sy-modify",
        "link": "/rules/no-sy-modify"
      },
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
        "text": "max-constructor-statements",
        "link": "/rules/max-constructor-statements"
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
