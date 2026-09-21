# blog —— 个人静态站(GitHub Pages)+ 成品包下载(GitHub Releases)

纯静态站点:一堆 HTML/CSS/JS 文件,**没有构建步骤**。
网页由 **GitHub Pages** 免费托管,可执行文件全部放在 **GitHub Releases** 里
—— 仓库本身只有文本和网页,干净、体积小、可审查,二进制走 GitHub 的下载通道。

页面内容:每个辅助工具的成品包下载 + 使用说明文章。写作范围有意收窄 ——
只写「怎么用、有什么限制」,不写实现细节/逆向内容,不做多人游戏里能用的东西
(理由写在 `about.html`,站点上也是这么说的)。

## 目录

```
index.html            首页:下载列表 + 文章列表
projects.html         项目与下载:每个包的完整信息、SHA256、使用范围
about.html            关于:放什么 / 不放什么 / 免责声明
posts/
  tf2-aimbot.html     泰坦陨落 2 战役辅助:功能、用法、下载
  rdr2-aimbot.html    荒野大镖客 2 剧情模式辅助:部署与配置
assets/
  style.css           样式(浅色/深色跟随系统)
  site.js             渲染脚本:把 downloads.js 的数据画成列表/卡片/按钮
  downloads.js        ⚠ 脚本生成,别手改
  config.js           ⚠ 唯一需要你改的文件:站点名、仓库名
scripts/
  add_release.py      登记一个版本(算 SHA256、写 downloads.js)
.gitattributes        行尾统一(压缩包按二进制)
.nojekyll             让 Pages 原样发布,不做 Jekyll 处理
```

仓库里**没有** `download/` 目录,也没有任何 `.exe/.zip` —— 那是刻意的。

## 本地预览

```bat
cd blog
python -m http.server 8000
rem 打开 http://localhost:8000/
```

## 一次性配置

1. **建仓库**:<https://github.com/new>,名字随意(比如 `blog`)。
   免费账号的 Pages **要求仓库公开**(私有仓库开 Pages 需要 GitHub Pro)。
   > 想让站点直接在 `https://你的用户名.github.io/` 根路径下(不带仓库名后缀),
   > 仓库名就叫 `你的用户名.github.io`;所有页面用的都是相对链接,两种都支持。

2. **推送**:

   ```bat
   git init -b main
   git add -A
   git commit -m "blog: 首次发布"
   git remote add origin https://github.com/你的用户名/blog.git
   git push -u origin main
   ```

3. **开 Pages**:仓库 → Settings → Pages → *Source* 选 `Deploy from a branch`,
   *Branch* 选 `main` + `/ (root)` → Save。等 1~2 分钟,
   站点在 `https://你的用户名.github.io/blog/`(或根路径)。

4. **配置(通常不用改)**:站点在 GitHub Pages 上会自动从地址里推出仓库名 ——
   `https://<用户名>.github.io/<仓库名>/` → 下载链接指向 `<用户名>/<仓库名>` 的 Releases;
   如果仓库名叫 `<用户名>.github.io`(用户站)也能正确识别。
   只有这两种情况需要动手编辑 `assets/config.js` 的 `repo`:
   - 绑了**自定义域名**(地址里看不出仓库名);
   - **站点仓库和放 Release 的仓库不是同一个**。
   留空且推断不出来时,下载按钮不会变成死链,而是提示还没配。

## 发一个新版本

两步:**先在 GitHub 上发 Release,再更新页面数据**。

1. 构建产物(以 tf2-aimbot 为例):

   ```bat
   cd ..\tf2-aimbot
   dist\package.bat
   ```

2. 在博客仓库里创建 Release,tag 用版本号,把 zip 作为附件传上去:

   - **网页**:仓库 → Releases → *Draft a new release* → Choose a tag 输入 `v1.0`
     (Create new tag) → 标题随便 → 把 zip 拖进附件区 → Publish release。
     附件名保持原样(`tf2-aimbot-v1.0.zip`),**改名会让页面上的链接 404**。
   - **或 gh CLI**(本机没装的话:`winget install GitHub.cli`,然后 `gh auth login`):

     ```bat
     gh release create v1.0 ..\tf2-aimbot\dist\tf2-aimbot-v1.0.zip
     ```

3. 告诉博客这个版本存在:

   ```bat
   cd ..\blog
   python scripts\add_release.py --id tf2-aimbot ^
     --zip ..\tf2-aimbot\dist\tf2-aimbot-v1.0.zip ^
     --version v1.0 --date 2026-09-21
   git add -A && git commit -m "release: tf2-aimbot v1.0" && git push
   ```

4. **点一下页面上的下载按钮**(或 `curl -I` 脚本打印出来的那个链接),确认能下到文件。
   这一步别跳:附件名和脚本记录的名字只要有一个字符不一样,链接就是 404。

- **只有 `--zip` / `--version` / `--date` 是每次要给的**;名称、游戏、说明、注意事项、
  标签、Release tag 都从上一版继承,要改再带上对应参数即可
  (`--name` / `--game` / `--scope` / `--game-version` / `--summary` / `--note` /
  `--label` / `--tag`(Release tag)/ `--guide`)。
- 查看当前状态(含拼好的下载链接):`python scripts\add_release.py --list`
- 撤掉一个包:`python scripts\add_release.py --id tf2-aimbot --remove`
  (只从页面移除;Release 本身要删的话去仓库 UI 里删)
- 页面只显示最新版;旧版仍在 Releases 里,别人拿到的旧链接依然能下。
- 更新完记得改文章里的「更新记录」和限制说明(脚本不管文字部分)。

## 加一篇文章

1. 复制 `posts/tf2-aimbot.html` 成新文件(导航链接里的 `../` 别删)。
2. 改 `<title>`、`<h1>`、`.meta` 那行日期、正文。
3. 在 `index.html` 的「说明文章」列表里加一条。
4. 需要下载按钮时用占位符,文件名和校验值都由脚本提供,别手写:

   ```html
   <div class="actions" data-download-button="tf2-aimbot" data-label="下载 tf2-aimbot-v1.0.zip"></div>
   <p class="muted">SHA256:<span data-download-hash="tf2-aimbot"></span></p>
   ```

## 自定义域名(可选)

仓库根目录放一个 `CNAME` 文件,内容写域名;再在仓库 Settings → Pages 里填 Custom domain,
并在域名商那边把 DNS 指向 GitHub Pages。开了 HTTPS 之后记得在设置里勾上强制 HTTPS。

## 想低调一点(可选)

- 不想被搜索引擎收录:在每个页面的 `<head>` 里加
  `<meta name="robots" content="noindex,nofollow">`;或放 `robots.txt` 写
  `User-agent: *` / `Disallow: /`。注意这只挡得住守规矩的爬虫,
  仓库名和 Release 在 GitHub 上仍是公开可搜的。
- 只想给特定几个人:把包放**私有仓库**的 Releases(需要登录且有权限才能下),
  但那样就不能用免费 Pages 了 —— 直接发文件更省事。

## 为什么二进制走 Releases 而不是放仓库里

- Pages 站点有体积与流量软限制(约 1 GB / 每月 100 GB),附件下载还会算在站点流量里;
  Releases 附件是单独的存储与下载通道(单文件上限 2 GB),不计入 Pages 流量。
- 仓库里只有文本,clone 快、diff 干净、审查一眼看完;可执行文件不进 git 历史。
- Release 天然带版本、tag、附件的 SHA256,和页面上的校验值一一对应。

## 关于风险的实话

- 这些包是给单人模式用的工具,但「发布作弊/修改工具」这件事本身可能踩到平台规则:
  GitHub 的 Acceptable Use Policies 明确限制「用平台直接支持非法攻击、投递恶意程序」,
  杀毒引擎也常把加载器类程序归为可疑 —— 结果是**Release 附件可能被扫描告警,
  也可能收到游戏发行商的 DMCA/下架通知**。
- 降低这种概率的实际做法:只放自己写的东西(不打包任何游戏文件)、不写规避检测的内容、
  站点上写清只用于单人模式、不提供多人可用的版本(本站已经这么做);仓库里不放可执行文件,
  被扫描面也小很多。
- 最后:账号是你自己的,发不发、发多少,你自己判断。
