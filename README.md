# blog

Static site for game-assist tools: pages on GitHub Pages, binaries on GitHub
Releases. No build step, no dependencies, no executables in the repo.

- Site: <https://seewpx.github.io/blog/>
- Releases: <https://github.com/seewpx/blog/releases>

## Layout

```
index.html               home: download list + post list
projects.html            per-package details, SHA256, scope
about.html               about / scope
posts/*.html             one post per package (usage, keys, limits)
assets/style.css         styles (light/dark follows system preference)
assets/site.js           renders release data into lists, cards, buttons
assets/downloads.js      generated - do not edit
assets/config.js         site title + release repo (see below)
scripts/add_release.py   register a version: size, sha256, tag, asset name
scripts/import_shot.ps1  screenshot (.jxr / .png) -> web-ready JPEG
.nojekyll                publish files as-is (no Jekyll)
```

## Preview

```bat
python -m http.server 8000    rem http://localhost:8000/
```

## Publish

```bat
git push origin main
```

Pages setup: Settings → Pages → *Deploy from a branch* → `main` / `/ (root)`.
The free plan requires a public repo. A push rebuilds the site in ~1–3 minutes.

## Release a version

1. Build the artifact (for tf2-aimbot: `dist\package.bat`).
2. Create a release in this repo, tagged with the version, with the zip attached:

   ```bat
   gh release create v1.1 ..\tf2-aimbot\dist\tf2-aimbot-v1.1.zip
   ```

   Keep the asset file name exactly as built — the page links to it by name.
3. Register it so the pages know about it:

   ```bat
   python scripts\add_release.py --id tf2-aimbot ^
     --zip ..\tf2-aimbot\dist\tf2-aimbot-v1.1.zip --version v1.1 --date 2026-10-02
   ```

   After the first time only `--zip / --version / --date` are needed: name, game,
   scope, notes, labels and tag are inherited from the previous entry, and can be
   overridden with `--name / --game / --scope / --summary / --note / --label /
   --tag / --game-version / --guide`. Other commands:

   ```bat
   python scripts\add_release.py --list               rem entries + resolved links
   python scripts\add_release.py --id tf2-aimbot --remove
   ```

4. Commit, push, then open the download link once to confirm it resolves.

## Add a post

Copy `posts/tf2-aimbot.html`, edit `<title>` / `<h1>` / the `.meta` date line and
the body (keep the `../` in the nav links), then add a line to the post list in
`index.html`. Download buttons and checksums are rendered from the data file:

```html
<div class="actions" data-download-button="tf2-aimbot"></div>
<span data-download-hash="tf2-aimbot"></span>
```

## Add a screenshot

```bat
powershell -File scripts\import_shot.ps1 -Src <shot.jxr|png> -Name tf2-aimbot-02
```

Writes `assets\shots\<Name>.jpg` — scaled to 1600 px wide, JPEG quality 88
(`-Width` / `-Quality` to change). `.jxr` works because the script decodes through
Windows Imaging Component, so nothing needs installing. Markup for the post:

```html
<figure class="shot">
  <img src="../assets/shots/tf2-aimbot-02.jpg" width="1600" height="900"
       loading="lazy" alt="...">
  <figcaption>Caption.</figcaption>
</figure>
```

## Which repo hosts the releases

`assets/config.js` → `SITE.repo`. Left empty, `site.js` derives it from the page
URL: `<user>.github.io/<repo>/` → `<user>/<repo>` (user sites included). Set it
explicitly only for a custom domain, or when the releases live in another repo.
With neither, cards show an "unconfigured" note instead of a dead link.

## Keeping it out of search results

Add `<meta name="robots" content="noindex,nofollow">` to each page head, or ship a
`robots.txt` with `Disallow: /`.
