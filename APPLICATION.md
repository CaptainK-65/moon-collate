# MoonCollate — Unicode 排序与比较基础库

项目仓库：https://github.com/CaptainK-65/moon-collate

项目方向：MoonBit 通用生态库 / Unicode 与国际化基础设施

MoonCollate 面向 MoonBit 生态实现 Unicode Collation Algorithm（UCA）与
Default Unicode Collation Element Table（DUCET）。它解决 Unicode 字符串不能
依靠码点顺序获得符合用户预期的排序问题，为数据库、表格、文件管理器、搜索、
国际化界面和内容工具提供可复用的多级比较与 Sort Key 能力。

核心交付包括 Unicode 17.0.0 DUCET 与 NFD 数据生成、规范等价处理、contraction
与 expansion、非连续 contraction、隐式权重、Primary 至 Identical 多级比较、
Non-Ignorable/Shifted 策略、结构化 Sort Key、数值排序、可解释比较轨迹、稳定
集合排序与缓存索引、CLI，以及复用同一 MoonBit 核心的浏览器 Collation Lab。
项目已经通过 Unicode 官方短版 CollationTest：Non-Ignorable 208,039 对、
Shifted 229,829 对，均为 0 失败；39 项测试在 native、js、wasm、wasm-gc 四个
后端全部通过。

本项目为依据 Unicode 标准与公开数据完成的原创实现，不是 ICU 或其他语言库的
代码移植。MoonBit 现有的 normalization、UCD、bidi、grapheme、i18n 与排版库
分别覆盖规范化、字符属性、显示方向、文本分割、消息格式化和布局；未发现公开的
MoonBit UCA、DUCET、Collator 或通用 Sort Key 实现。因现有 MoonBit 规范化包
仍采用 Unicode 16 数据，项目仅内置 UCA 所需的 Unicode 17 canonical
decomposition 与 combining class 子集，以保证版本一致性，不扩展为通用规范化库。
仓库持续维护独立生态查重报告，并明确声明相邻项目和功能边界。

项目采用 Apache-2.0 许可证；Unicode 数据保留 Unicode License v3 与来源说明。
所有功能通过 Issues、Actions、Milestone 和 Release 形成可追踪的开发与验收链；
公开 Collation Lab 由 GitHub Pages 自动部署。
