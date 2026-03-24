# 🔍 vendor-assessment-qcc

> **企查查MCP供应商评估Skill** - 为中国供应商提供9维度深度风险评估

[![License](https://img.shields.io/badge/License-Apache%202.0-green.svg)](LICENSE)
[![Claude](https://img.shields.io/badge/Claude%20Code-Compatible-purple.svg)](https://claude.ai)
[![MCP](https://img.shields.io/badge/MCP-QCC%20企查查-orange.svg)](https://mcp.qcc.com)
[![Original](https://img.shields.io/badge/Original-Panaversity-blue.svg)](https://github.com/panaversity/agentfactory-business-plugins)

> **⚠️ 重要说明：本项目基于 [Panaversity Supply Chain Plugin](https://github.com/panaversity/agentfactory-business-plugins) 增强开发**
>
> 在保留原作者所有代码的基础上，增加了企查查MCP集成、9维度评估模型和供应链特有功能。

---

## 📋 目录

- [功能概述](#功能概述)
- [快速开始](#快速开始)
- [安装指南](#安装指南)
- [使用方法](#使用方法)
- [9维度评估模型](#9维度评估模型)
- [18类风险清单](#18类风险清单)
- [Kraljic矩阵分类](#kraljic矩阵分类)
- [项目结构](#项目结构)
- [贡献与反馈](#贡献与反馈)
- [致谢](#致谢)
- [许可证](#许可证)

---

## 功能概述

### 解决什么问题？

传统供应商评估对中国企业存在**数据盲区**：
- ❌ Companies House 无中国数据
- ❌ Creditsafe 无中国覆盖
- ❌ 手动查询耗时2-3天
- ❌ 非上市公司财务不可见

### 我们的方案

集成 **企查查MCP**，为中国供应商提供：
- ✅ **实体锚定** - 统一社会信用代码验证
- ✅ **18类风险** - 司法/经营/税务/破产全覆盖
- ✅ **9维度评估** - 基础6维 + 供应链特有3维
- ✅ **实时数据** - 官方数据源直连
- ✅ **3秒评估** - 自动化风险扫描

---

## 快速开始

### 1分钟快速体验（一键安装）

```bash
# 1. 一键安装（自动配置 MCP）
bash <(curl -sL https://raw.githubusercontent.com/duhu2000/vendor-assessment-qcc/main/install_qcc_mcp.sh)

# 2. 配置API Key（从 https://mcp.qcc.com 申请）
export QCC_MCP_API_KEY="your_api_key_here"

# 3. ⚠️ 重要：重启 Claude Code 以加载 MCP 配置
# 完全退出 Claude Code，然后重新启动

# 4. 验证 MCP 配置（重启后）
# 你应该能看到可用的 MCP 工具：qcc-company, qcc-risk, qcc-ipr, qcc-operation

# 5. 开始评估
/vendor-assessment-qcc 华为技术有限公司
```

### 手动安装

```bash
# 1. 克隆仓库
git clone https://github.com/duhu2000/vendor-assessment-qcc.git

# 2. 进入目录
cd vendor-assessment-qcc

# 3. 运行安装脚本
bash install_qcc_mcp.sh

# 4. 配置API Key
export QCC_MCP_API_KEY="your_api_key_here"

# 5. ⚠️ 重启 Claude Code（关键步骤）
# 完全退出后重新启动

# 6. 开始评估
/vendor-assessment-qcc 华为技术有限公司
```

---

## 安装指南

### 系统要求

- **操作系统**: macOS / Linux / Windows (WSL)
- **Claude Code**: 最新版本
- **网络**: 可访问 https://mcp.qcc.com

### 安装步骤

#### 步骤1: 申请企查查MCP Key

1. 访问 [企查查MCP官网](https://mcp.qcc.com)
2. 注册企业账号
3. 申请MCP服务授权
4. 获取API Key

#### 步骤2: 配置环境变量

**临时配置（当前终端）:**
```bash
export QCC_MCP_API_KEY="your_api_key_here"
```

**永久配置（推荐）- 添加到 `~/.zshrc` 或 `~/.bashrc`:**
```bash
export QCC_MCP_API_KEY="your_api_key_here"
```

#### 步骤3: 安装Skill

```bash
# 创建Skill目录
mkdir -p ~/.claude/skills/vendor-assessment-qcc

# 复制增强版Skill（推荐）
cp SKILL.qcc-enhanced.md ~/.claude/skills/vendor-assessment-qcc/SKILL.md

# 或复制标准版Skill
cp SKILL.original.md ~/.claude/skills/vendor-assessment-qcc/SKILL.md
```

---

## 使用方法

### 在Claude Code中使用

#### 供应商评估

```
# 基础评估
/vendor-assessment-qcc 供应商名称

# 示例
/vendor-assessment-qcc 华为技术有限公司
/vendor-assessment-qcc 阿里巴巴集团
/vendor-assessment-qcc 广州宇辰鞋业科技有限公司
```

### 在Python代码中使用

```python
from qcc_mcp_integration.qcc_mcp_connector import QccMcpConnector

# 初始化连接器
connector = QccMcpConnector()

# 完整评估（9维度）
profile = connector.assess_vendor_risk("供应商名称")

# 查看评估结果
print(f"整体风险: {profile.overall_risk}")
print(f"产能资质风险: {profile.capacity_risk}")      # 供应链特有
print(f"组织稳定性风险: {profile.stability_risk}")   # 供应链特有
print(f"业务健康度风险: {profile.business_health_risk}")  # 供应链特有

# 单独评估供应链特有维度
capacity = connector.assess_capacity_and_qualification("供应商名称")
stability = connector.assess_organizational_stability("供应商名称")
health = connector.assess_business_health("供应商名称")
```

---

## 9维度评估模型

### 基础6维度（Panaversity原版）

| 维度 | 说明 | 评估内容 |
|------|------|---------|
| 商业风险 | 合同与交易 | 合同状态、付款条款、自动续约 |
| 运营风险 | 交付能力 | OTD、交期方差、质量拒收率 |
| 财务风险 | 资金健康 | 股权冻结、欠税、破产 |
| 合规风险 | 认证与处罚 | ISO认证、环保处罚、行政处罚 |
| 战略风险 | 依赖程度 | 唯一来源、切换成本、替代方案 |
| 地缘政治风险 | 宏观环境 | 国家风险、汇率、二级供应商 |

### 供应链特有3维度 ⭐（QCC MCP增强）

| 维度 | 说明 | 数据来源 | 关键指标 |
|------|------|---------|---------|
| **产能资质风险** | 生产许可、质量认证 | QCC MCP Operation | 生产许可证、ISO认证、排污许可 |
| **组织稳定性风险** | 股权变更、单点风险 | QCC MCP Enterprise | 分支机构数、股权变更次数、法人变更 |
| **业务健康度风险** | 信用评级、招投标 | QCC MCP Operation | 官方信用评级、招投标活跃度、抽查记录 |

---

## 18类风险清单

### 🔴 CRITICAL（立即供应中断）

| 风险类型 | 供应链影响 | 响应时间 |
|---------|-----------|---------|
| 破产重整 | 供应关系终止 | < 4小时 |
| 失信信息 | 信用崩溃 | < 4小时 |
| 被执行人 | 现金流危机 | < 24小时 |
| 环保处罚(停产) | 生产被迫停止 | < 24小时 |
| 经营异常 | 监管介入 | < 48小时 |

### 🔴 HIGH（供应不稳定）

| 风险类型 | 供应链影响 | 响应时间 |
|---------|-----------|---------|
| 严重违法 | 可能吊销执照 | < 48小时 |
| 注销备案 | 主动终止经营 | < 48小时 |
| 股权冻结 | 控制权不稳定 | < 48小时 |
| 限高消费 | 法人受限 | < 48小时 |

### 🟡 MEDIUM（财务/合规风险）

- 股权出质、欠税、税务异常、终本案件、动产抵押

### 🔵 LOW（一般合规风险）

- 一般行政处罚

---

## Kraljic矩阵分类

评估前首先对供应商进行分类：

| 维度 | Strategic<br>战略型 | Tactical<br>杠杆型 | Commodity<br>常规型 | Bottleneck<br>瓶颈型 |
|------|-------------------|-------------------|-------------------|-------------------|
| **替代可用性** | 无/极少 | 是（2-3家） | 很多 | 无/极少 |
| **年采购额** | 高 | 中 | 任意 | 低-中 |
| **失败影响** | 关键 | 显著 | 可管理 | 关键 |
| **关系深度** | 深/长期 | 已建立 | 交易型 | 可变 |
| **评估频率** | 季度+事件触发 | 半年+事件触发 | 年度 | 季度 |

**⚠️ 重要规则**：低采购额但唯一来源的供应商必须分类为 **Bottleneck（瓶颈型）**，无论金额大小。

---

## 项目结构

```
vendor-assessment-qcc/
├── README.md                           # 本文件
├── LICENSE                             # Apache 2.0 许可证
├── install_qcc_mcp.sh                  # 一键安装脚本 ⭐
│
├── SKILL.md                            # 当前使用的Skill文件
├── SKILL.original.md                   # 原作者Panaversity版本（6维度）
├── SKILL.qcc-enhanced.md               # QCC MCP增强版（9维度）⭐推荐
│
├── qcc-mcp-integration/                # QCC MCP连接器代码
│   └── qcc_mcp_connector.py            # 核心连接器
│
├── evals/                              # 评估配置
│   └── eval_vendor_assessment.md
│
└── trigger_eval_set.json               # 触发评估集配置
```

### 文件说明

| 文件 | 说明 | 使用场景 |
|------|------|---------|
| `SKILL.original.md` | Panaversity原版 | 不需要中国数据时使用 |
| `SKILL.qcc-enhanced.md` | QCC MCP增强版 ⭐ | **推荐**：评估中国供应商 |
| `SKILL.md` | 当前生效版本 | 复制自上述两个版本之一 |

---

## 贡献与反馈

### 提交Issue

- Bug反馈
- 功能建议
- 文档改进

### 提交PR

1. Fork本仓库
2. 创建feature分支 (`git checkout -b feature/amazing-feature`)
3. 提交修改 (`git commit -m 'Add some amazing feature'`)
4. 推送到分支 (`git push origin feature/amazing-feature`)
5. 创建Pull Request

### 联系方式

- **企查查MCP官网**: [https://mcp.qcc.com](https://mcp.qcc.com)
- **Email**: duhu@qcc.com

---

## 致谢

- 原版作者 [Panaversity](https://github.com/panaversity/agentfactory-business-plugins) 的优秀供应商评估框架
- [企查查MCP](https://mcp.qcc.com) - Agent-Native企业数据基座
- [Anthropic](https://anthropic.com) 的 Claude Code

---

## 许可证

Apache License 2.0

基于 [Panaversity/agentfactory-business-plugins](https://github.com/panaversity/agentfactory-business-plugins) 构建

---

<div align="center">

**让中国供应商评估从"数据盲区"走向"全面透视"** 🔍

如果这个项目对您有帮助，请 ⭐ Star 支持！

[提交Issue](https://github.com/duhu2000/vendor-assessment-qcc/issues) · [贡献代码](https://github.com/duhu2000/vendor-assessment-qcc/pulls)

</div>
