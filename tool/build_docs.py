"""Build portable Markdown indexes from the route catalog and captured images."""
from pathlib import Path
import re

ROOT = Path(__file__).resolve().parent.parent
source = (ROOT / 'lib/data/catalog.dart').read_text(encoding='utf-8')
screens = re.findall(r"ScreenSpec\(\s*'([^']+)',\s*'([^']+)',\s*'([^']+)',\s*'([^']+)'", source)
assert len(screens) == 47, f'Expected 47 Pixso frames, found {len(screens)}'

index = ['# Pixso 页面与 Flutter 路由对应表', '', '共 47 个手机画板。参考图来自 Pixso，实拍图来自运行中的 Flutter App。', '', '| 分类 | 页面 | Pixso 节点 | 路由 | 参考 | 实拍 |', '| --- | --- | --- | --- | --- | --- |']
gallery = ['# DeliverEat 界面截图', '', 'Android 模拟器实拍。截图使用预置的购物车、收藏和订单数据；首次启动的真实应用从空购物车开始。', '', '[返回项目说明](../README.md) · [页面对应表](页面清单.md)', '']
current = None
for route, title, node, group in screens:
    filename = node.replace(':', '-') + '.png'
    assert (ROOT / 'docs/screenshots' / filename).exists(), f'Missing screenshot: {filename}'
    assert (ROOT / 'docs/design' / filename).exists(), f'Missing reference: {filename}'
    index.append(f'| {group} | {title} | `{node}` | `{route}` | [参考](design/{filename}) | [实拍](screenshots/{filename}) |')
    if group != current:
        gallery += [f'## {group}', '']
        current = group
    gallery += [f'### {title}', '', f'Pixso `{node}` · 路由 `{route}`', '', f'<img src="screenshots/{filename}" width="280" alt="{title}">', '']

index += ['', '首页和个人中心是长页面，额外底部截图如下：', '', '- [首页底部](screenshots/101-1708-bottom.png)', '- [个人中心底部](screenshots/128-170-bottom.png)', '']
gallery += ['## 长页面补充', '', '<img src="screenshots/101-1708-bottom.png" width="280" alt="首页底部"> <img src="screenshots/128-170-bottom.png" width="280" alt="个人中心底部">', '']
(ROOT / 'docs/页面清单.md').write_text('\n'.join(index), encoding='utf-8')
(ROOT / 'docs/界面截图.md').write_text('\n'.join(gallery), encoding='utf-8')
print(f'Indexed {len(screens)} frames and 49 screenshots.')
