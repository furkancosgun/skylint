<script setup>
import { computed, ref } from 'vue';
import { withBase } from 'vitepress';
import catalogData from './catalog-data.json';

const rules = catalogData.rules;
const categories = catalogData.categories.filter((category) => category.count > 0);

const query = ref('');
const selectedCategory = ref('ALL');
const onlyConfigurable = ref(false);
const onlyQuickfix = ref(false);
const onlyLocal = ref(false);

const configurableCount = rules.filter((rule) => rule.configurable).length;
const quickfixCount = rules.filter((rule) => rule.hasQuickfix).length;
const localCount = rules.filter((rule) => !rule.remoteEnabled).length;

const hasActiveFilters = computed(
  () =>
    query.value.trim() !== '' ||
    selectedCategory.value !== 'ALL' ||
    onlyConfigurable.value ||
    onlyQuickfix.value ||
    onlyLocal.value
);

const filteredRules = computed(() => {
  const search = query.value.trim().toLowerCase();

  return rules.filter((rule) => {
    if (selectedCategory.value !== 'ALL' && rule.category !== selectedCategory.value) return false;
    if (onlyConfigurable.value && !rule.configurable) return false;
    if (onlyQuickfix.value && !rule.hasQuickfix) return false;
    if (onlyLocal.value && rule.remoteEnabled) return false;

    if (!search) return true;

    return [rule.ruleId, rule.title, rule.className, rule.description, rule.pseudoComment, rule.categoryTitle]
      .join(' ')
      .toLowerCase()
      .includes(search);
  });
});

const visibleCategories = computed(() =>
  categories
    .filter((category) => selectedCategory.value === 'ALL' || category.key === selectedCategory.value)
    .map((category) => ({
      ...category,
      rules: filteredRules.value.filter((rule) => rule.category === category.key),
    }))
    .filter((category) => category.rules.length > 0)
);

function resetFilters() {
  query.value = '';
  selectedCategory.value = 'ALL';
  onlyConfigurable.value = false;
  onlyQuickfix.value = false;
  onlyLocal.value = false;
}
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

      <div class="catalog-pills">
        <button
          type="button"
          class="catalog-pill"
          :class="{ active: selectedCategory === 'ALL' }"
          :aria-pressed="selectedCategory === 'ALL'"
          @click="selectedCategory = 'ALL'"
        >
          All ({{ rules.length }})
        </button>
        <button
          v-for="category in categories"
          :key="category.key"
          type="button"
          class="catalog-pill"
          :class="{ active: selectedCategory === category.key }"
          :aria-pressed="selectedCategory === category.key"
          @click="selectedCategory = category.key"
        >
          {{ category.title }} ({{ category.count }})
        </button>

        <span class="catalog-divider" aria-hidden="true"></span>

        <button
          type="button"
          class="catalog-pill toggle"
          :class="{ active: onlyConfigurable }"
          :aria-pressed="onlyConfigurable"
          @click="onlyConfigurable = !onlyConfigurable"
        >
          Configurable ({{ configurableCount }})
        </button>
        <button
          type="button"
          class="catalog-pill toggle"
          :class="{ active: onlyQuickfix }"
          :aria-pressed="onlyQuickfix"
          @click="onlyQuickfix = !onlyQuickfix"
        >
          QuickFix ({{ quickfixCount }})
        </button>
        <button
          type="button"
          class="catalog-pill toggle"
          :class="{ active: onlyLocal }"
          :aria-pressed="onlyLocal"
          @click="onlyLocal = !onlyLocal"
        >
          Local Only ({{ localCount }})
        </button>

        <button v-if="hasActiveFilters" type="button" class="catalog-reset" @click="resetFilters">
          Reset filters
        </button>
      </div>
    </div>

    <section v-for="category in visibleCategories" :id="category.key" :key="category.key" class="catalog-category">
      <h2>{{ category.title }} ({{ category.rules.length }})</h2>
      <p>{{ category.description }}</p>

      <div class="catalog-table-wrap">
        <table class="catalog-table">
          <thead>
            <tr>
              <th>Rule</th>
              <th>ABAP Class</th>
              <th>Description</th>
              <th>Suppression</th>
              <th class="center">QuickFix</th>
              <th class="center">Remote</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="rule in category.rules" :key="rule.ruleId">
              <td>
                <a :href="withBase(`/rules/${rule.ruleId}`)"><code>{{ rule.ruleId }}</code></a>
              </td>
              <td><code>{{ rule.className }}</code></td>
              <td>{{ rule.description }}</td>
              <td><code>#EC {{ rule.pseudoComment }}</code></td>
              <td class="center">{{ rule.hasQuickfix ? 'Yes' : 'No' }}</td>
              <td class="center">{{ rule.remoteEnabled ? 'Yes' : 'No' }}</td>
            </tr>
          </tbody>
        </table>
      </div>
    </section>

    <p v-if="visibleCategories.length === 0" class="catalog-empty">
      No rules match the current filters.
      <button type="button" @click="resetFilters">Clear filters</button>
    </p>
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
  display: flex;
  flex-direction: column;
  gap: 0.65rem;
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

.catalog-pills {
  display: flex;
  align-items: center;
  flex-wrap: wrap;
  gap: 0.4rem;
}

.catalog-pill {
  padding: 0.3rem 0.65rem;
  border: 1px solid var(--vp-c-divider);
  border-radius: 999px;
  background: var(--vp-c-bg-soft);
  color: var(--vp-c-text-2);
  font-family: inherit;
  font-size: 0.78rem;
  cursor: pointer;
  transition: border-color 0.2s ease, background-color 0.2s ease, color 0.2s ease;
}

.catalog-pill:hover {
  border-color: var(--vp-c-brand-1);
  color: var(--vp-c-text-1);
}

.catalog-pill.active {
  border-color: var(--vp-c-brand-1);
  background: var(--vp-c-brand-1);
  color: #fff;
  font-weight: 600;
}

.catalog-pill.toggle.active {
  background: var(--vp-c-brand-soft);
  color: var(--vp-c-brand-1);
}

.catalog-divider {
  width: 1px;
  height: 20px;
  margin: 0 0.25rem;
  background: var(--vp-c-divider);
}

.catalog-reset {
  padding: 0.3rem 0.55rem;
  border: 0;
  background: transparent;
  color: var(--vp-c-brand-1);
  font-family: inherit;
  font-size: 0.78rem;
  font-weight: 600;
  cursor: pointer;
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
  padding: 0.55rem 0.75rem;
  border: 0;
  background: var(--vp-c-bg-soft);
  color: var(--vp-c-text-1);
  font-size: 0.75rem;
  text-align: left;
  white-space: nowrap;
}

.catalog-table td {
  padding: 0.55rem 0.75rem;
  border: 0;
  border-top: 1px solid var(--vp-c-divider);
  vertical-align: top;
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

.catalog-table .center {
  text-align: center;
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

@media (max-width: 720px) {
  .catalog-search-row {
    flex-direction: column;
    align-items: stretch;
    gap: 0.5rem;
  }

  .catalog-count {
    text-align: right;
  }
}
</style>
