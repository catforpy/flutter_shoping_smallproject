library;

import 'package:flutter/material.dart';

/// 分类标签模型
class CategoryTag {
  final String id;
  final String name;

  const CategoryTag({
    required this.id,
    required this.name,
  });
}

/// 分类页面
class CategoryPage extends StatefulWidget {
  const CategoryPage({super.key});

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  /// 选中的标签索引
  int _selectedTagIndex = 0;

  /// 分类标签列表
  static const List<CategoryTag> _categoryTags = [
    CategoryTag(id: '1', name: '前端开发'),
    CategoryTag(id: '2', name: '后端开发'),
    CategoryTag(id: '3', name: 'AI人工智能'),
    CategoryTag(id: '4', name: '新授课程'),
    CategoryTag(id: '5', name: '计算机基础'),
    CategoryTag(id: '6', name: '前沿技术'),
    CategoryTag(id: '7', name: '移动开发'),
    CategoryTag(id: '8', name: '云计算&\n大数据'),
    CategoryTag(id: '9', name: '运维&测试'),
    CategoryTag(id: '10', name: '数据库'),
    CategoryTag(id: '11', name: '产品设计'),
    CategoryTag(id: '12', name: '嵌入式开发'),
    CategoryTag(id: '13', name: '求职面试'),
    CategoryTag(id: '14', name: '软考/\n认证'),
    CategoryTag(id: '15', name: '算法'),
    CategoryTag(id: '16', name: '通识类课程'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // AppBar 由 MainShell 提供（搜索框 + 购物车图标）
      body: Row(
        children: [
          // 左侧标签导航栏
          _buildSideTagBar(),
          // 右侧内容区域
          Expanded(
            child: _buildContentArea(),
          ),
        ],
      ),
    );
  }

  /// 构建侧边标签导航栏
  Widget _buildSideTagBar() {
    return Container(
      width: MediaQuery.of(context).size.width / 4,
      constraints: const BoxConstraints(
        maxWidth: 120, // 最大宽度限制
      ),
      color: Colors.grey[100],
      child: ListView.builder(
        itemCount: _categoryTags.length,
        itemBuilder: (context, index) {
          final tag = _categoryTags[index];
          final isSelected = _selectedTagIndex == index;

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedTagIndex = index;
              });
            },
            child: Container(
              // 固定高度，确保标签大小一致
              height: 60,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: isSelected ? Colors.white : Colors.transparent,
                border: Border(
                  bottom: BorderSide(
                    color: Colors.grey[300]!,
                    width: 0.5,
                  ),
                ),
              ),
              child: Row(
                children: [
                  // 红色选中指示器（竖线）
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 3,
                    height: isSelected ? 20 : 0,
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.red : Colors.transparent,
                      borderRadius: BorderRadius.circular(1.5),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // 标签文字
                  Expanded(
                    child: Center(
                      child: Text(
                        tag.name,
                        style: TextStyle(
                          fontSize: 13,
                          color: isSelected ? Colors.red : Colors.grey[700],
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// 构建内容区域
  Widget _buildContentArea() {
    final selectedTag = _categoryTags[_selectedTagIndex];

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          // 图片卡片列表（16:5宽高比）
          _buildImageCards(selectedTag),
          const SizedBox(height: 24),
          // 分隔线
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Divider(color: Colors.grey[300], thickness: 1),
          ),
          const SizedBox(height: 16),
          // 图标列表标题
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              '热门分类',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          const SizedBox(height: 16),
          // 圆形图标列表（每3个一横排）
          _buildIconGrid(selectedTag),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  /// 构建图片卡片列表
  Widget _buildImageCards(CategoryTag tag) {
    // 为每个标签生成不同的示例数据
    final cards = _getMockImageCards(tag);

    return Column(
      children: cards.map((cardData) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: double.infinity,
            height: 120, // 16:5宽高比
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // 背景图片
                Image.network(
                  cardData['imageUrl'] as String,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: _getTagColor(tag.id),
                      child: Center(
                        child: Icon(
                          cardData['icon'] as IconData,
                          size: 48,
                          color: Colors.white70,
                        ),
                      ),
                    );
                  },
                ),
                // 渐变遮罩
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.7),
                      ],
                    ),
                  ),
                ),
                // 文字内容
                Positioned(
                  bottom: 16,
                  left: 16,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        cardData['title'] as String,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        cardData['subtitle'] as String,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      )).toList(),
    );
  }

  /// 构建图标网格（每3个一横排）
  Widget _buildIconGrid(CategoryTag tag) {
    final icons = _getMockIconItems(tag);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Wrap(
        spacing: 24,
        runSpacing: 24,
        children: icons.map((item) => SizedBox(
          width: (MediaQuery.of(context).size.width - 32 - 120) / 3 - 16, // 计算每个item的宽度
          child: Column(
            children: [
              // 圆形图标
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: item['color'] as Color,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  item['icon'] as IconData,
                  size: 28,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              // 文字标签
              Text(
                item['label'] as String,
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        )).toList(),
      ),
    );
  }

  /// 获取标签对应的颜色
  Color _getTagColor(String tagId) {
    final colors = {
      '1': Colors.blue,
      '2': Colors.green,
      '3': Colors.purple,
      '4': Colors.orange,
      '5': Colors.teal,
      '6': Colors.red,
      '7': Colors.indigo,
      '8': Colors.cyan,
      '9': Colors.amber,
      '10': Colors.brown,
      '11': Colors.pink,
      '12': Colors.deepOrange,
      '13': Colors.lime,
      '14': Colors.lightBlue,
      '15': Colors.deepPurple,
      '16': Colors.lightGreen,
    };
    return colors[tagId] ?? Colors.blue;
  }

  /// 获取图片卡片模拟数据
  List<Map<String, dynamic>> _getMockImageCards(CategoryTag tag) {
    // 根据不同标签返回不同的示例数据
    return [
      {
        'title': '${tag.name}精选课程',
        'subtitle': '火热报名中',
        'imageUrl': 'https://picsum.photos/800/250?random=${tag.id}1',
        'icon': Icons.play_circle_outline,
      },
      {
        'title': '${tag.name}实战项目',
        'subtitle': '从零到一掌握',
        'imageUrl': 'https://picsum.photos/800/250?random=${tag.id}2',
        'icon': Icons.code,
      },
    ];
  }

  /// 获取图标项模拟数据
  List<Map<String, dynamic>> _getMockIconItems(CategoryTag tag) {
    // 所有图标项（18个）
    final allIcons = [
      {'label': 'Java', 'icon': Icons.code, 'color': Colors.blue},
      {'label': 'Python', 'icon': Icons.language, 'color': Colors.green},
      {'label': 'JavaScript', 'icon': Icons.javascript, 'color': Colors.yellow},
      {'label': 'Flutter', 'icon': Icons.phone_android, 'color': Colors.cyan},
      {'label': 'React', 'icon': Icons.web, 'color': Colors.blue},
      {'label': 'Vue', 'icon': Icons.web_asset, 'color': Colors.green},
      {'label': 'Spring', 'icon': Icons.eco, 'color': Colors.lightGreen},
      {'label': 'Django', 'icon': Icons.security, 'color': Colors.green},
      {'label': 'MySQL', 'icon': Icons.storage, 'color': Colors.blue},
      {'label': 'Redis', 'icon': Icons.flash_on, 'color': Colors.red},
      {'label': 'MongoDB', 'icon': Icons.folder, 'color': Colors.green},
      {'label': 'Git', 'icon': Icons.source, 'color': Colors.orange},
      {'label': 'Docker', 'icon': Icons.layers, 'color': Colors.blue},
      {'label': 'Linux', 'icon': Icons.computer, 'color': Colors.grey},
      {'label': 'Node.js', 'icon': Icons.hexagon_outlined, 'color': Colors.green},
      {'label': 'TypeScript', 'icon': Icons.text_fields, 'color': Colors.blue},
      {'label': 'Go', 'icon': Icons.bolt, 'color': Colors.cyan},
      {'label': 'Kotlin', 'icon': Icons.smartphone, 'color': Colors.purple},
    ];

    // 每个标签固定返回9个图标项（3行 x 3列）
    const itemCount = 9;
    final tagIndex = int.parse(tag.id) - 1;
    final startIndex = (tagIndex * 3) % allIcons.length;

    // 循环取图标，确保始终返回9个
    final result = <Map<String, dynamic>>[];
    for (int i = 0; i < itemCount; i++) {
      final index = (startIndex + i) % allIcons.length;
      result.add(allIcons[index]);
    }

    return result;
  }
}
