#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Markdown 文章转 WordPress HTML 工具

功能：
  将 doc/articles 目录下的 Markdown 文件转换为静态 HTML，
  适合直接复制到 WordPress 博客系统。

使用方法：
  在 doc 目录下运行：
    python3 convert_articles.py
  
  脚本会自动：
    1. 扫描 articles/ 目录下的所有 .md 文件
    2. 转换为 HTML 格式
    3. 输出到 articles/html/ 目录

依赖安装：
  首次使用需要安装 markdown 库：
    pip install markdown --break-system-packages

输出特性：
  - 纯静态内容，无 JavaScript
  - 内联 CSS 样式
  - 代码块格式：<pre class="lang:c++ decode:true">
  - 兼容常见 WordPress 语法高亮插件（如 Crayon Syntax Highlighter）
  - 支持语言映射：cpp→c++, py→python 等

支持的语言标记：
  cpp, c, python, javascript, java, bash, html, css, sql 等

复制到 WordPress：
  在 WordPress 编辑器中切换到"文本"模式，将生成的 HTML 中
  <body> 标签内的内容复制粘贴即可。

故障排查：
  - 提示找不到 markdown 模块：pip install markdown --break-system-packages
  - 找不到 Markdown 文件：确保在 doc 目录下运行脚本
  - 代码块格式不对：检查 Markdown 中代码块是否使用了正确的语言标记
"""

import os
import sys
import re
from pathlib import Path

try:
    import markdown
    from markdown.extensions import fenced_code, tables, codehilite
except ImportError:
    print("错误: 需要安装 markdown 库")
    print("请运行: pip install markdown")
    sys.exit(1)

# 语言名称映射（markdown -> WordPress）
LANGUAGE_MAP = {
    'cpp': 'c++',
    'c++': 'c++',
    'c': 'c',
    'python': 'python',
    'py': 'python',
    'javascript': 'javascript',
    'js': 'javascript',
    'java': 'java',
    'bash': 'bash',
    'sh': 'bash',
    'shell': 'bash',
    'html': 'html',
    'css': 'css',
    'sql': 'sql',
    'xml': 'xml',
    'json': 'javascript',
}

# 内联 CSS 样式 - 适合复制到 WordPress
HTML_STYLE = """
<style>
body {
    font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif;
    line-height: 1.6;
    color: #333;
    max-width: 800px;
    margin: 0 auto;
    padding: 20px;
}

h1 {
    color: #2c3e50;
    border-bottom: 3px solid #3498db;
    padding-bottom: 10px;
    margin-top: 30px;
}

h2 {
    color: #34495e;
    border-bottom: 2px solid #95a5a6;
    padding-bottom: 8px;
    margin-top: 25px;
}

h3 {
    color: #34495e;
    margin-top: 20px;
}

code {
    background-color: #f4f4f4;
    padding: 2px 6px;
    border-radius: 3px;
    font-family: "Consolas", "Monaco", "Courier New", monospace;
    font-size: 0.9em;
}

pre {
    background-color: #f8f8f8;
    border: 1px solid #ddd;
    border-radius: 5px;
    padding: 15px;
    overflow-x: auto;
}

pre code {
    background-color: transparent;
    padding: 0;
    font-size: 0.85em;
}

blockquote {
    border-left: 4px solid #3498db;
    padding-left: 15px;
    color: #555;
    margin: 15px 0;
    font-style: italic;
}

img {
    max-width: 100%;
    height: auto;
    display: block;
    margin: 20px auto;
    border-radius: 5px;
    box-shadow: 0 2px 8px rgba(0,0,0,0.1);
}

table {
    border-collapse: collapse;
    width: 100%;
    margin: 20px 0;
}

table th, table td {
    border: 1px solid #ddd;
    padding: 10px;
    text-align: left;
}

table th {
    background-color: #3498db;
    color: white;
    font-weight: bold;
}

table tr:nth-child(even) {
    background-color: #f9f9f9;
}

ul, ol {
    padding-left: 30px;
    margin: 15px 0;
}

li {
    margin: 8px 0;
}

a {
    color: #3498db;
    text-decoration: none;
}

a:hover {
    text-decoration: underline;
}

strong {
    color: #2c3e50;
}
</style>
"""

def convert_latex_formulas(html_content):
    """
    将 LaTeX 数学公式转换为 WordPress 兼容格式
    - 单行公式 $...$ 转换为 [latex]...[/latex]
    - 块级公式 $$...$$ 保持原样或转换为块级 LaTeX 标记
    
    Args:
        html_content: 原始 HTML 内容
        
    Returns:
        转换后的 HTML 内容
    """
    # 先处理块级公式 $$...$$（避免与单行公式冲突）
    # 块级公式通常在 <p> 标签中，转换为单独的段落
    def replace_block_latex(match):
        latex_content = match.group(1).strip()
        return f'<p style="text-align: center;">[latex display="true"]{latex_content}[/latex]</p>'
    
    # 匹配 $$...$$ 格式（非贪婪匹配）
    html_content = re.sub(r'\$\$(.*?)\$\$', replace_block_latex, html_content, flags=re.DOTALL)
    
    # 处理单行公式 $...$
    # 需要注意：避免匹配已经转换过的块级公式
    def replace_inline_latex(match):
        latex_content = match.group(1).strip()
        return f'[latex]{latex_content}[/latex]'
    
    # 匹配单个 $ 包裹的内容（非贪婪匹配，且不跨多行）
    html_content = re.sub(r'\$([^\$\n]+?)\$', replace_inline_latex, html_content)
    
    return html_content

def convert_code_blocks_for_wordpress(html_content):
    """
    将标准的 <pre><code class="language-xxx"></code></pre> 格式
    转换为 WordPress 插件需要的 <pre class="lang:xxx decode:true"></pre> 格式
    
    Args:
        html_content: 原始 HTML 内容
        
    Returns:
        转换后的 HTML 内容
    """
    # 匹配 <pre><code class="language-xxx">...</code></pre> 格式
    pattern = r'<pre><code class="language-([^"]+)">(.*?)</code></pre>'
    
    def replace_code_block(match):
        lang = match.group(1).lower()
        code_content = match.group(2)
        
        # 映射语言名称
        wp_lang = LANGUAGE_MAP.get(lang, lang)
        
        # 返回 WordPress 格式
        return f'<pre class="lang:{wp_lang} decode:true">{code_content}</pre>'
    
    # 执行替换（使用 DOTALL 标志让 . 匹配换行符）
    result = re.sub(pattern, replace_code_block, html_content, flags=re.DOTALL)
    
    # 处理没有指定语言的代码块 <pre><code>...</code></pre>
    pattern_no_lang = r'<pre><code>(.*?)</code></pre>'
    
    def replace_code_block_no_lang(match):
        code_content = match.group(1)
        # 默认使用 plain 或不指定语言
        return f'<pre class="decode:true">{code_content}</pre>'
    
    result = re.sub(pattern_no_lang, replace_code_block_no_lang, result, flags=re.DOTALL)
    
    return result

def convert_markdown_to_html(md_file_path, output_file_path):
    """
    将单个 Markdown 文件转换为 HTML
    
    Args:
        md_file_path: 输入的 Markdown 文件路径
        output_file_path: 输出的 HTML 文件路径
    """
    # 读取 Markdown 文件
    with open(md_file_path, 'r', encoding='utf-8') as f:
        md_content = f.read()
    
    # 配置 markdown 扩展
    extensions = [
        'markdown.extensions.fenced_code',  # 代码块支持
        'markdown.extensions.tables',        # 表格支持
        'markdown.extensions.nl2br',         # 换行支持
        'markdown.extensions.sane_lists',    # 更好的列表支持
    ]
    
    # 转换为 HTML
    html_content = markdown.markdown(md_content, extensions=extensions)
    
    # 转换 LaTeX 公式为 WordPress 兼容格式
    html_content = convert_latex_formulas(html_content)
    
    # 转换代码块格式为 WordPress 兼容格式
    html_content = convert_code_blocks_for_wordpress(html_content)
    
    # 提取标题作为文件名（从第一个 h1 标签）
    title = Path(md_file_path).stem.replace('_', ' ').title()
    if '<h1>' in html_content:
        title_start = html_content.find('<h1>') + 4
        title_end = html_content.find('</h1>')
        if title_start < title_end:
            title = html_content[title_start:title_end]
    
    # 创建完整的 HTML 文档
    full_html = f"""<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>{title}</title>
{HTML_STYLE}
</head>
<body>
{html_content}
</body>
</html>
"""
    
    # 写入 HTML 文件
    with open(output_file_path, 'w', encoding='utf-8') as f:
        f.write(full_html)
    
    print(f"✓ 已转换: {md_file_path.name} -> {output_file_path.name}")

def main():
    """主函数"""
    # 获取脚本所在目录
    script_dir = Path(__file__).parent.resolve()
    
    # 设置目录路径（相对于脚本位置）
    articles_dir = script_dir / "articles"
    output_dir = script_dir / "articles" / "html"
    
    # 确保输出目录存在
    output_dir.mkdir(parents=True, exist_ok=True)
    
    # 获取所有 Markdown 文件
    md_files = list(articles_dir.glob("*.md"))
    
    if not md_files:
        print(f"错误: 在 {articles_dir} 目录下没有找到 Markdown 文件")
        return 1
    
    print(f"找到 {len(md_files)} 个 Markdown 文件")
    print("-" * 50)
    
    # 转换所有文件
    success_count = 0
    for md_file in md_files:
        try:
            output_file = output_dir / f"{md_file.stem}.html"
            convert_markdown_to_html(md_file, output_file)
            success_count += 1
        except Exception as e:
            print(f"✗ 转换失败: {md_file.name} - {e}")
            import traceback
            traceback.print_exc()
    
    print("-" * 50)
    print(f"转换完成! 成功: {success_count}/{len(md_files)}")
    print(f"输出目录: {output_dir}")
    
    return 0

if __name__ == "__main__":
    sys.exit(main())
