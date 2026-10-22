import { defineConfig } from 'vitepress';

const base = process.env.VITEPRESS_BASE || '/';

export default defineConfig({
  title: 'Skylint',
  titleTemplate: ':title | Enterprise Clean ABAP & Cloud ATC Linter',
  description: 'Enterprise Clean ABAP & Cloud ATC Linter Engine',
  base,
  cleanUrls: true,
  lastUpdated: true,
  appearance: 'dark',
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
          'description': 'Enterprise Clean ABAP & Cloud ATC Linter Engine with 108+ Native Rules',
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
      { text: 'Rules (108)', link: '/rules/' },
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
    "link": "/rules/#clean-abap"
  },
  {
    "text": "Anti-Patterns & Bad Practices",
    "link": "/rules/#anti-patterns"
  },
  {
    "text": "Performance & Database",
    "link": "/rules/#performance"
  },
  {
    "text": "Security & Robustness",
    "link": "/rules/#security"
  },
  {
    "text": "Metrics & Complexity Limits",
    "link": "/rules/#metrics"
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
