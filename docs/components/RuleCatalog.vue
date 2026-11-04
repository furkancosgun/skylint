<script setup>
import { computed, ref } from 'vue';
import { withBase } from 'vitepress';
import catalogData from './catalog-data.json';

const props = defineProps({
  category: {
    type: String,
    default: '',
  },
});

const rules = computed(() =>
  props.category
    ? catalogData.rules.filter((rule) => rule.category === props.category)
    : catalogData.rules
);

const categories = computed(() => {
  const allCats = catalogData.categories.filter((category) => category.count > 0);
  return props.category
    ? allCats.filter((category) => category.key === props.category)
    : allCats;
});

const query = ref('');

const filteredRules = computed(() => {
  const search = query.value.trim().toLowerCase();
  if (!search) return rules.value;

  return rules.value.filter((rule) => {
    return [rule.ruleId, rule.title, rule.className, rule.description, rule.pseudoComment, rule.categoryTitle]
      .join(' ')
      .toLowerCase()
      .includes(search);
  });
});

const visibleCategories = computed(() =>
  categories.value
    .map((category) => ({
      ...category,
      rules: filteredRules.value.filter((rule) => rule.category === category.key),
    }))
    .filter((category) => category.rules.length > 0)
);
</script>

<template>
  <div class="catalog">
    <div class="catalog-toolbar">
      <div class="catalog-search-row">
        <div class="catalog-search">
          <svg class="catalog-search-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" aria-hidden="true">
            <circle cx="11" cy="11" r="8" />
            <path d="m21 21-4.35-4.35" />
          </svg>
          <input
            v-model="query"
            type="search"
            :placeholder="`Search ${rules.length} rules by ID, class, description, or #EC code...`"
            aria-label="Search rules"
          />
          <button v-if="query" class="catalog-clear" type="button" aria-label="Clear search" @click="query = ''">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" aria-hidden="true">
              <path d="M18 6 6 18M6 6l12 12" />
            </svg>
          </button>
        </div>
        <span class="catalog-count" aria-live="polite">{{ filteredRules.length }} / {{ rules.length }} rules</span>
      </div>
    </div>

    <section v-for="category in visibleCategories" :id="category.key" :key="category.key" class="catalog-category">
      <template v-if="!props.category">
        <h2>{{ category.title }} ({{ category.rules.length }})</h2>
        <p>{{ category.description }}</p>
      </template>

      <div class="catalog-table-wrap">
        <table class="catalog-table">
          <thead>
            <tr>
              <th>Rule</th>
              <th>Description</th>
              <th class="center">QuickFix</th>
              <th class="center">Remote</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="rule in category.rules" :key="rule.ruleId">
              <td data-label="Rule">
                <a :href="withBase(`/rules/${rule.ruleId}`)"><code>{{ rule.ruleId }}</code></a>
              </td>
              <td data-label="Description">{{ rule.description }}</td>
              <td class="center" data-label="QuickFix">
                <span
                  class="catalog-icon"
                  :class="{ active: rule.hasQuickfix }"
                  :title="rule.hasQuickfix ? 'QuickFix available' : 'No QuickFix'"
                >
                  <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" aria-hidden="true">
                    <path d="M13 2 4 14h6l-1 8 9-12h-6l1-8Z" />
                  </svg>
                </span>
              </td>
              <td class="center" data-label="Remote">
                <span
                  class="catalog-icon"
                  :class="{ active: rule.remoteEnabled }"
                  :title="rule.remoteEnabled ? 'Remote enabled' : 'Local only'"
                >
                  <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" aria-hidden="true">
                    <circle cx="12" cy="12" r="10"/>
                    <path d="M12 2a14.5 14.5 0 0 0 0 20M12 2a14.5 14.5 0 0 1 0 20M2 12h20"/>
                  </svg>
                </span>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </section>

    <p v-if="visibleCategories.length === 0" class="catalog-empty">
      No rules match the current search.
      <button type="button" @click="query = ''">Clear search</button>
    </p>

    <div v-if="props.category" class="catalog-back-link">
      <a :href="withBase('/rules/')">← Back to All Rules Catalog</a>
    </div>

    <div class="catalog-community-footer">
      <span>Looking for a Clean ABAP rule that is not in Skylint yet?</span>
      <a
        href="https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml"
        target="_blank"
        rel="noopener noreferrer"
        class="catalog-proposal-link"
      >
        💡 Propose a Rule
      </a>
    </div>
  </div>
</template>

<style scoped>
.catalog {
  margin-top: 1rem;
}

.catalog-toolbar {
  position: sticky;
  top: var(--vp-nav-height);
  z-index: 10;
  margin-bottom: 1.5rem;
  padding: 0.75rem 0;
  border-bottom: 1px solid var(--vp-c-divider);
  background: color-mix(in srgb, var(--vp-c-bg) 90%, transparent);
  backdrop-filter: blur(12px);
}

.catalog-search-row {
  display: flex;
  align-items: center;
  gap: 1rem;
}

.catalog-search {
  position: relative;
  flex: 1;
  max-width: 640px;
}

.catalog-search-icon {
  position: absolute;
  left: 0.8rem;
  top: 50%;
  width: 16px;
  height: 16px;
  color: var(--vp-c-text-3);
  transform: translateY(-50%);
}

.catalog-search input {
  width: 100%;
  padding: 0.55rem 2.3rem 0.55rem 2.35rem;
  border: 1px solid var(--vp-c-divider);
  border-radius: 8px;
  background: var(--vp-c-bg-soft);
  color: var(--vp-c-text-1);
  font-size: 0.88rem;
}

.catalog-search input:focus {
  outline: none;
  border-color: var(--vp-c-brand-1);
  background: var(--vp-c-bg);
}

.catalog-clear {
  position: absolute;
  right: 0.65rem;
  top: 50%;
  display: flex;
  padding: 0.25rem;
  border: 0;
  background: transparent;
  color: var(--vp-c-text-3);
  cursor: pointer;
  transform: translateY(-50%);
}

.catalog-clear svg {
  width: 14px;
  height: 14px;
}

.catalog-count {
  color: var(--vp-c-text-3);
  font-size: 0.8rem;
  white-space: nowrap;
}

.catalog-category {
  margin-bottom: 2rem;
  scroll-margin-top: calc(var(--vp-nav-height) + 150px);
}

.catalog-category h2 {
  margin-top: 0;
}

.catalog-table-wrap {
  overflow-x: auto;
  border: 1px solid var(--vp-c-divider);
  border-radius: 8px;
}

.catalog-table {
  display: table;
  width: 100%;
  margin: 0;
  border-collapse: collapse;
  font-size: 0.85rem;
}

.catalog-table th {
  padding: 0.6rem 0.85rem;
  border: 0;
  background: var(--vp-c-bg-soft);
  color: var(--vp-c-text-1);
  font-size: 0.78rem;
  text-align: left;
  white-space: nowrap;
}

.catalog-table td {
  padding: 0.65rem 0.85rem;
  border: 0;
  border-top: 1px solid var(--vp-c-divider);
  vertical-align: middle;
}

.catalog-table th.center,
.catalog-table td.center {
  text-align: center;
  width: 90px;
}

.catalog-table tbody tr:hover {
  background: var(--vp-c-brand-softest);
}

.catalog-table code {
  font-size: 0.78rem;
}

.catalog-table a {
  text-decoration: none;
}

/* Status Icons (QuickFix & Remote - Variant Builder Style) */
.catalog-icon {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  color: var(--vp-c-text-3);
  opacity: 0.25;
  transition: color 0.15s ease, opacity 0.15s ease;
}

.catalog-icon.active {
  color: var(--vp-c-brand-1);
  opacity: 1;
}

.catalog-icon svg {
  width: 17px;
  height: 17px;
}

.catalog-empty {
  padding: 2rem 1rem;
  border: 1px dashed var(--vp-c-divider);
  border-radius: 8px;
  color: var(--vp-c-text-2);
  text-align: center;
}

.catalog-empty button {
  margin-left: 0.35rem;
  border: 0;
  background: transparent;
  color: var(--vp-c-brand-1);
  font-weight: 600;
  cursor: pointer;
}

.catalog-back-link {
  margin-top: 2rem;
  padding-top: 1rem;
  border-top: 1px solid var(--vp-c-divider);
}

.catalog-back-link a {
  color: var(--vp-c-brand-1);
  font-size: 0.88rem;
  font-weight: 500;
  text-decoration: none;
}

.catalog-back-link a:hover {
  text-decoration: underline;
}

@media (max-width: 900px) {
  .catalog-toolbar {
    position: static;
  }
}

@media (max-width: 720px) {
  .catalog-toolbar {
    margin-bottom: 1rem;
    padding: 0.5rem 0 0.75rem;
  }

  .catalog-search-row {
    flex-direction: column;
    align-items: stretch;
    gap: 0.5rem;
  }

  .catalog-count {
    text-align: right;
  }

  .catalog-category {
    scroll-margin-top: calc(var(--vp-nav-height) + 16px);
  }

  .catalog-table-wrap {
    overflow: visible;
    border: 0;
    border-radius: 0;
  }

  .catalog-table {
    display: block;
    width: 100%;
    font-size: 0.84rem;
  }

  .catalog-table thead {
    display: none;
  }

  .catalog-table tbody {
    display: flex;
    flex-direction: column;
    gap: 0.6rem;
  }

  .catalog-table tr {
    display: block;
    padding: 0.75rem 0.85rem;
    border: 1px solid var(--vp-c-divider);
    border-radius: 8px;
    background: var(--vp-c-bg-soft);
  }

  .catalog-table td {
    display: block;
    padding: 0;
    border: 0;
    width: auto !important;
  }

  .catalog-table td[data-label="Rule"] {
    font-size: 0.9rem;
    font-weight: 600;
  }

  .catalog-table td[data-label="Description"] {
    margin: 0.35rem 0 0.6rem;
    color: var(--vp-c-text-2);
  }

  .catalog-table td.center {
    display: inline-flex;
    align-items: center;
    gap: 0.5rem;
    margin-right: 0.75rem;
    padding: 0.25rem 0.6rem;
    border: 1px solid var(--vp-c-divider);
    border-radius: 6px;
    background: var(--vp-c-bg);
    color: var(--vp-c-text-2);
    font-size: 0.78rem;
    text-align: left;
  }

  .catalog-table td.center::before {
    content: attr(data-label);
    color: var(--vp-c-text-2);
    font-weight: 500;
  }
}

.catalog-community-footer {
  margin-top: 2rem;
  padding: 1rem 1.25rem;
  border-radius: 8px;
  background: var(--vp-c-bg-soft);
  border: 1px solid var(--vp-c-divider);
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 1rem;
  font-size: 0.9rem;
  color: var(--vp-c-text-2);
}

.catalog-proposal-link {
  display: inline-flex;
  align-items: center;
  gap: 0.35rem;
  padding: 0.4rem 0.85rem;
  border-radius: 6px;
  background: var(--vp-c-brand-1);
  color: #fff !important;
  font-weight: 600;
  font-size: 0.85rem;
  text-decoration: none;
  transition: opacity 0.2s;
}

.catalog-proposal-link:hover {
  opacity: 0.9;
}

@media (max-width: 640px) {
  .catalog-community-footer {
    flex-direction: column;
    text-align: center;
  }
}
</style>
