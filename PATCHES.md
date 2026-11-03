# Upstream changes

Base release: `v4.19.1`. Record each changed upstream path here before merging it.

| Upstream path | Reason | Date | Handling an upstream update |
|---|---|---|---|
| `.gitignore` | Exclude local credentials, backups, dumps and index data | 2026-11-03 | Keep these exclusions and merge new upstream rules |
| `.github/workflows/*` | Remove publishing and maintenance jobs intended for the upstream project | 2026-11-03 | Remove reintroduced upstream workflows; preserve our own CI |
| `config/initializers/01_inject_enterprise_edition_module.rb` | `const_get_maybe_false` returns false when the extension namespace is missing; needed because `custom/` makes `extensions` list `enterprise` on the CE image | 2026-11-03 | Keep the `return false unless mod` guard |
| `config/application.rb` | Load `custom/` (eager-load paths, views after enterprise, initializers) to mirror `enterprise/` | 2026-11-03 | Re-add the 10-line block marked `Alien custom extension` after the enterprise initializers block |

Files added for this fork: `UPSTREAM_VERSION`, `PATCHES.md`, `README.alien.md`, `custom/`, `spec/custom/`.

No upstream file was edited for the Colombia phone normalizer. It adds `custom/app/services/whatsapp/phone_normalizers/colombia_phone_normalizer.rb` and `custom/config/initializers/colombia_phone_normalizer.rb`, which replaces `Whatsapp::PhoneNumberNormalizationService::NORMALIZERS` (read as a constant by `Whatsapp::WebhookChannelFinderService`). On an update, re-check that both still consume `NORMALIZERS` the same way.

## Super Admin branding (Phase 6)

One upstream file is edited: `app/views/layouts/vueapp.html.erb`. The three static `<link class="favicon" ...>` lines are replaced by `<%= render "custom/branding/favicon" %>`; the partial renders the same three links unless `ALIEN_FAVICON_URL` is set. On an update, re-apply this one-line swap and check that the layout still has only those favicon links.

The rest lives in `custom/`:
- `Custom::SuperAdmin::AppConfigsController` (hooked by the existing `prepend_mod_with`) serves the `custom_branding` page and handles uploads.
- `custom/config/initializers/branding.rb` adds `has_one_attached :branding_file` to `InstallationConfig` and prepends `Custom::SuperAdmin::FeaturesOverride` to `SuperAdmin::FeaturesHelper` to unlock the card. On an update, check that `InstallationConfig`, `SuperAdmin::FeaturesHelper.available_features` and the `custom_branding` entry in `features.yml` keep their shape.
- `ALIEN_FAVICON_URL` is an `InstallationConfig` row created on first save; `config/installation_config.yml` is untouched.
