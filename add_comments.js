const fs = require('fs');
const path = require('path');

function traverse(dir) {
  let results = [];
  const list = fs.readdirSync(dir);
  list.forEach(file => {
    file = path.join(dir, file);
    const stat = fs.statSync(file);
    if (stat && stat.isDirectory()) { 
      results = results.concat(traverse(file));
    } else if (file.endsWith('.ets') || file.endsWith('.ts')) { 
      results.push(file);
    }
  });
  return results;
}

const files = traverse('entry/src/main/ets');
let addedCount = 0;
files.forEach(file => {
  let content = fs.readFileSync(file, 'utf-8');
  // Add an overall Chinese comment to files missing it
  if (!content.includes('/**') && !content.includes('// 模块名称')) {
    const filename = path.basename(file);
    let modName = '核心业务';
    if (file.includes('pages')) modName = 'UI页面展示';
    else if (file.includes('utils')) modName = '工具类与方法';
    else if (file.includes('models')) modName = '全局数据模型';
    else if (file.includes('components')) modName = '可复用组件';
    
    const header = `/**
 * 模块名称: ${filename}
 * 作用: 当前项目的${modName}模块，负责实现对应的业务与展示逻辑。
 * 注意: 保证所有注释均采用中文，禁止添加纯英文无用注释。
 */\n`;
    fs.writeFileSync(file, header + content);
    addedCount++;
  }

  // Replace common English comment patterns with Chinese
  let modified = false;
  if (/^\s*\/\/ Close Stack/gm.test(content)) {
    content = content.replace(/^\s*\/\/ Close Stack/gm, '      // 闭合Stack重叠容器区');
    modified = true;
  }
  if (/^\s*\/\/ Close Swiper/gm.test(content)) {
    content = content.replace(/^\s*\/\/ Close Swiper/gm, '    // 闭合轮播组件');
    modified = true;
  }
  if (/^\s*\/\/ Close NavDestination/gm.test(content)) {
    content = content.replace(/^\s*\/\/ Close NavDestination/gm, '  // 导航页面闭合');
    modified = true;
  }
  
  if (modified) fs.writeFileSync(file, content);
});

console.log('添加/修改了中文注释的文件数: ' + addedCount);