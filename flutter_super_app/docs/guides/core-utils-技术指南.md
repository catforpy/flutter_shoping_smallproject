# Core Utils 技术指南

## 目录
- [概述](#概述)
- [架构设计](#架构设计)
- [核心组件](#核心组件)
- [使用指南](#使用指南)
- [API 参考](#api-参考)
- [最佳实践](#最佳实践)

---

## 概述

`core_utils` 是一个实用的工具函数库，提供各种扩展方法和工具类，简化日常开发工作。

### 核心特性

- **类型扩展**：为 String、DateTime、num 提供便捷扩展方法
- **数据验证**：内置常用数据格式验证器
- **数据格式化**：统一的数据格式化工具
- **媒体处理**：图片、视频、音频等媒体文件处理
- **零依赖**：除 Flutter 基础库外无其他依赖

### 包结构

```
core_utils
├── lib/
│   ├── src/
│   │   ├── extensions/       # 扩展方法
│   │   │   ├── string_extension.dart
│   │   │   ├── datetime_extension.dart
│   │   │   └── num_extension.dart
│   │   ├── utils/            # 工具类
│   │   │   ├── validator.dart
│   │   │   └── formatter.dart
│   │   └── media/            # 媒体工具
│   │       └── media_utils.dart
│   └── core_utils.dart       # 统一导出
└── test/
```

---

## 架构设计

### 扩展方法架构

```
┌─────────────────────────────────────────────────────────────────┐
│                      Extension Layer                            │
│  ┌───────────────┐  ┌───────────────┐  ┌───────────────┐       │
│  │ StringExt     │  │ DateTimeExt   │  │   NumExt      │       │
│  │               │  │               │  │               │       │
│  │ - 验证方法    │  │ - 日期判断    │  │ - 范围判断    │       │
│  │ - 格式转换    │  │ - 日期计算    │  │ - 格式化      │       │
│  │ - 字符串处理  │  │ - 时间格式化  │  │ - 单位转换    │       │
│  └───────────────┘  └───────────────┘  └───────────────┘       │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                       Utility Layer                             │
│  ┌───────────────┐  ┌───────────────┐  ┌───────────────┐       │
│  │   Validator   │  │   Formatter   │  │  MediaUtils   │       │
│  │               │  │               │  │               │       │
│  │ - 数据验证    │  │ - 数据格式化  │  │ - 文件处理    │       │
│  │ - 规则检查    │  │ - 信息隐藏    │  │ - 媒体识别    │       │
│  │ - 组合验证    │  │ - 单位转换    │  │ - 图片处理    │       │
│  └───────────────┘  └───────────────┘  └───────────────┘       │
└─────────────────────────────────────────────────────────────────┘
```

---

## 核心组件

### 1. String 扩展

#### 空值判断

```dart
String? name;

// 判断是否为空或 null
name.isNullOrEmpty  // bool
name.isNullOrBlank  // bool (去除首尾空格后判断)
```

#### 数据验证

```dart
// 手机号验证（中国大陆）
'13812345678'.isPhoneNumber  // true
'12345678901'.isPhoneNumber  // false

// 邮箱验证
'test@example.com'.isEmail  // true
'invalid.email'.isEmail     // false

// 身份证号验证
'110101199001011234'.isIdCard  // true

// URL 验证
'https://example.com'.isUrl    // true

// IPv4 地址验证
'192.168.1.1'.isIPv4           // true

// 纯数字验证
'12345'.isNumeric              // true
```

#### 敏感信息隐藏

```dart
// 隐藏手机号中间四位
'13812345678'.hidePhoneNumber  // '138****5678'

// 隐藏邮箱
'example@gmail.com'.hideEmail  // 'ex***@gmail.com'

// 隐藏身份证号
'110101199001011234'.hideIdCard  // '110101********1234'
```

#### 字符串处理

```dart
// 首字母大写
'hello'.capitalize  // 'Hello'

// 截取字符串并添加省略号
'这是一段很长的文本'.ellipsis(10)  // '这是一段很长的...'

// 移除所有空白字符
'hello  world'.removeAllWhitespace  // 'helloworld'

// 判断是否包含中文
'你好世界'.containsChinese  // true

// 转换为安全的文件名
'file<>name|txt'.toSafeFileName()  // 'file__name_txt'

// 类型转换
'123'.toIntOrNull()      // 123
'3.14'.toDoubleOrNull()  // 3.14
'abc'.toIntOrNull()      // null
```

### 2. DateTime 扩展

#### 日期判断

```dart
DateTime now = DateTime.now();

// 判断是否为今天/昨天/明天
now.isToday       // bool
now.isYesterday   // bool
now.isTomorrow    // bool

// Null 安全版本
DateTime? date;
date.isNull       // bool
date.isNotNull    // bool
```

#### 日期范围

```dart
DateTime date = DateTime(2024, 3, 15);

// 获取当天的开始和结束时间
date.startOfDay  // 2024-03-15 00:00:00
date.endOfDay    // 2024-03-15 23:59:59

// 获取当周的第一天和最后一天
date.startOfWeek  // 2024-03-11 00:00:00 (周一)
date.endOfWeek    // 2024-03-17 23:59:59 (周日)

// 获取当月的第一天和最后一天
date.startOfMonth  // 2024-03-01 00:00:00
date.endOfMonth    // 2024-03-31 23:59:59
```

#### 日期计算

```dart
DateTime date = DateTime(2024, 3, 15);

// 添加天数
date.addDays(7)  // 2024-03-22

// 添加月数
date.addMonths(1)  // 2024-04-15

// 添加年数
date.addYears(1)   // 2025-03-15

// 计算两个日期之间的天数差
DateTime other = DateTime(2024, 3, 20);
date.daysBetween(other)  // 5
```

#### 日期格式化

```dart
DateTime date = DateTime(2024, 3, 15, 14, 30, 45);

// 自定义格式化
date.format('yyyy-MM-dd HH:mm:ss')  // '2024-03-15 14:30:45'

// 预定义格式
date.toDateString       // '2024-03-15'
date.toTimeString       // '14:30:45'
date.toDateTimeString   // '2024-03-15 14:30:45'

// 相对时间描述
DateTime.now().subtract(Duration(minutes: 5)).toRelativeTime  // '5分钟前'
DateTime.now().subtract(Duration(hours: 2)).toRelativeTime    // '2小时前'
DateTime.now().subtract(Duration(days: 7)).toRelativeTime     // '7天前'
DateTime.now().subtract(Duration(days: 40)).toRelativeTime    // '1个月前'
```

### 3. num 扩展

#### 数值判断

```dart
int? value;

// Null 安全判断
value.isNull      // bool
value.isNotNull   // bool

// 数值状态判断
value.isZero      // bool
value.isPositive  // bool (大于 0)
value.isNegative  // bool (小于 0)

// 范围判断
value.isBetween(1, 100)  // bool (1 <= value <= 100)
```

#### 数值限制

```dart
double value = 150;

// 限制在指定范围内
value.clamp(0, 100)  // 100
(-10).clamp(0, 100)   // 0
50.clamp(0, 100)      // 50
```

#### 数值格式化

```dart
// 文件大小格式化
1024.toFileSize          // '1.00 KB'
1048576.toFileSize       // '1.00 MB'
1073741824.toFileSize    // '1.00 GB'

// 货币格式化
1234.567.toCurrency()           // '¥1234.57'
1234.567.toCurrency('¥', 2)     // '¥1234.57'
1234.567.toCurrency('$', 2)     // '$1234.57'
1234.567.toCurrency('¥', 0)     // '¥1235'

// 百分比格式化
0.1234.toPercent()      // '12%'
0.1234.toPercent(2)     // '12.34%'
0.5.toPercent(1)        // '50.0%'

// 保留小数位
3.1415926.toFixedNum(2)  // 3.14

// 类型转换
123.45.toIntOrNull()     // 123
100.toDoubleOrNull()     // 100.0
```

### 4. Validator 验证器

#### 单项验证

```dart
// 手机号验证
Validator.isPhoneNumber('13812345678')  // true

// 邮箱验证
Validator.isEmail('test@example.com')  // true

// 身份证号验证
Validator.isIdCard('110101199001011234')  // true

// URL 验证
Validator.isUrl('https://example.com')  // true

// 用户名验证（4-20位，字母数字下划线）
Validator.isUsername('user_123')  // true

// 密码验证（8-20位，至少包含字母和数字）
Validator.isPassword('abc12345')  // true

// 验证码验证（6位数字）
Validator.isVerificationCode('123456')  // true

// 车牌号验证
Validator.isLicensePlate('京A12345')  // true

// 银行卡号验证
Validator.isBankCard('6222021234567890')  // true

// 微信号验证
Validator.isWeChatId('wechat_id_123')  // true

// QQ 号验证
Validator.isQQ('123456789')  // true

// 邮政编码验证
Validator.isPostalCode('100000')  // true

// Hex 颜色值验证
Validator.isHexColor('#FF0000')  // true
Validator.isHexColor('F00')      // true

// IP 地址验证
Validator.isIP('192.168.1.1')  // true

// 经纬度验证
Validator.isLongitude('116.404')  // true
Validator.isLatitude('39.915')    // true

// 年龄验证
Validator.isAge('25')  // true
```

#### 组合验证

```dart
final result = Validator.validate(
  phone: '13812345678',
  email: 'test@example.com',
  password: 'abc12345',
  username: 'user_123',
);

if (result.isValid) {
  print('验证通过');
} else {
  print(result.firstError);  // 获取第一个错误
  print(result.getErrorFor('phone'));  // 获取指定字段错误
  print(result.errors);  // 所有错误 {field: message}
}
```

### 5. Formatter 格式化器

#### 敏感信息格式化

```dart
// 格式化手机号
Formatter.formatPhone('13812345678')  // '138****5678'

// 格式化邮箱
Formatter.formatEmail('example@gmail.com')  // 'ex***@gmail.com'

// 格式化身份证号
Formatter.formatIdCard('110101199001011234')  // '110101********1234'

// 格式化银行卡号（每4位加空格）
Formatter.formatBankCard('6222021234567890')  // '6222 0212 3456 7890'
```

#### 金额格式化

```dart
// 格式化金额（带千分位）
Formatter.formatMoney(1234567.891)  // '¥1,234,567.89'

// 自定义符号和小数位
Formatter.formatMoney(1234.5, symbol: '$', decimals: 2)  // '$1,234.50'
Formatter.formatMoney(1234.5, showSymbol: false)  // '1,234.50'
```

#### 数字格式化

```dart
// 格式化为中文
Formatter.formatNumberToChinese(123)  // '一百二十三'
Formatter.formatNumberToChinese(10086)  // '一万零八十六'

// 格式化百分比
Formatter.formatPercent(0.1234)  // '12%'
Formatter.formatPercent(0.1234, decimals: 2)  // '12.34%'
Formatter.formatPercent(0.1234, showSign: true)  // '+12%'
```

#### 时间格式化

```dart
DateTime date = DateTime(2024, 3, 15, 14, 30, 45);

// 日期时间格式化
Formatter.formatDateTime(date)  // '2024-03-15 14:30:45'
Formatter.formatDateTime(date, pattern: 'MM/dd')  // '03/15'

// 相对时间格式化
Formatter.formatRelativeTime(date.subtract(Duration(minutes: 5)))  // '5分钟前'

// 时长格式化
Formatter.formatDuration(3665)  // '01:01:05' (1小时1分5秒)
Formatter.formatDuration(65)    // '01:05' (1分5秒)
```

#### 其他格式化

```dart
// 文件大小格式化
Formatter.formatFileSize(1024)  // '1.00 KB'
Formatter.formatFileSize(1048576)  // '1.00 MB'

// 经纬度格式化
Formatter.formatCoordinate(116.404, 39.915)  // '116.404000,39.915000'

// 文本截断
Formatter.truncate('这是一段很长的文本', 10)  // '这是一段很长的...'

// 关键词高亮
Formatter.highlightKeyword('这是一个关键词示例', '关键词')  // '这是一个[关键词]示例'
```

### 6. MediaUtils 媒体工具

#### 文件类型判断

```dart
// 判断是否为图片文件
MediaUtils.isImageFile('/path/to/image.jpg')   // true
MediaUtils.isImageFile('/path/to/image.png')   // true
MediaUtils.isImageFile('/path/to/document.pdf') // false

// 判断是否为视频文件
MediaUtils.isVideoFile('/path/to/video.mp4')   // true
MediaUtils.isVideoFile('/path/to/video.mov')   // true

// 判断是否为音频文件
MediaUtils.isAudioFile('/path/to/audio.mp3')   // true
MediaUtils.isAudioFile('/path/to/audio.wav')   // true

// 获取图片类型
MediaUtils.getImageType('/path/to/image.jpg')  // 'jpeg'
MediaUtils.getImageType('/path/to/image.png')  // 'png'
```

#### 文件信息获取

```dart
// 获取文件名
MediaUtils.getFileName('/path/to/file.txt')  // 'file.txt'

// 获取文件扩展名
MediaUtils.getFileExtension('/path/to/file.txt')  // 'txt'

// 格式化文件大小
MediaUtils.formatFileSize(1024)           // '1.00 KB'
MediaUtils.formatFileSize(1048576)        // '1.00 MB'
MediaUtils.formatFileSize(1073741824)     // '1.00 GB'

// 获取文件大小
final size = await MediaUtils.getFileSize('/path/to/file.txt');

// 检查文件是否存在
final exists = await MediaUtils.fileExists('/path/to/file.txt');
```

#### 文件操作

```dart
// 删除文件
final success = await MediaUtils.deleteFile('/path/to/file.txt');

// 获取文件对象
final file = MediaUtils.getFile('/path/to/file.txt');

// 创建临时文件
final bytes = Uint8List.fromList([0x00, 0x01, 0x02]);
final tempFile = await MediaUtils.createTempFile('temp.bin', bytes);
```

#### 图片处理

```dart
// 计算图片宽高比
double ratio = MediaUtils.calculateAspectRatio(1920, 1080);  // 1.777...

// 根据宽高比调整尺寸
Size size = MediaUtils.adjustSizeByAspectRatio(300, 16/9);  // Size(300.0, 168.75)

// 图片尺寸信息
ImageSize imageSize = ImageSize(width: 1920, height: 1080);
print(imageSize.aspectRatio);  // 1.777...
```

#### 媒体信息

```dart
MediaInfo info = MediaInfo(
  path: '/path/to/image.jpg',
  name: 'image.jpg',
  type: 'jpeg',
  size: 102400,
  width: 1920,
  height: 1080,
  createdAt: DateTime.now(),
);

// 属性访问
info.isImage        // true
info.isVideo        // false
info.formattedSize  // '100.00 KB'
info.imageSize      // ImageSize(width: 1920, height: 1080)
```

---

## 使用指南

### 场景 1：用户信息验证

```dart
class UserRegistrationPage extends StatefulWidget {
  @override
  _UserRegistrationPageState createState() => _UserRegistrationPageState();
}

class _UserRegistrationPageState extends State<UserRegistrationPage> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  String? _phoneError;
  String? _emailError;
  String? _passwordError;

  void _validate() {
    setState(() {
      _phoneError = null;
      _emailError = null;
      _passwordError = null;
    });

    final phone = _phoneController.text;
    final email = _emailController.text;
    final password = _passwordController.text;

    // 使用 Validator 验证
    if (!phone.isPhoneNumber) {
      setState(() => _phoneError = '请输入正确的手机号');
      return;
    }

    if (!email.isEmail) {
      setState(() => _emailError = '请输入正确的邮箱');
      return;
    }

    if (!password.isPassword) {
      setState(() => _passwordError = '密码必须为8-20位，且包含字母和数字');
      return;
    }

    // 验证通过，提交表单
    _submit();
  }

  void _submit() {
    // ...
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _phoneController,
            decoration: InputDecoration(
              labelText: '手机号',
              errorText: _phoneError,
            ),
            keyboardType: TextInputType.phone,
          ),
          TextFormField(
            controller: _emailController,
            decoration: InputDecoration(
              labelText: '邮箱',
              errorText: _emailError,
            ),
            keyboardType: TextInputType.emailAddress,
          ),
          TextFormField(
            controller: _passwordController,
            decoration: InputDecoration(
              labelText: '密码',
              errorText: _passwordError,
            ),
            obscureText: true,
          ),
          ElevatedButton(
            onPressed: _validate,
            child: Text('注册'),
          ),
        ],
      ),
    );
  }
}
```

### 场景 2：时间显示

```dart
class MessageTile extends StatelessWidget {
  final Message message;

  const MessageTile({required this.message});

  String _formatTime(DateTime time) {
    // 今天显示时间，昨天显示"昨天"，更早显示日期
    if (time.isToday) {
      return time.format('HH:mm')!;
    } else if (time.isYesterday) {
      return '昨天 ${time.format('HH:mm')}';
    } else {
      return time.format('yyyy-MM-dd HH:mm')!;
    }
  }

  String _getRelativeTime(DateTime time) {
    return time.toRelativeTime ?? '未知时间';
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(message.content),
      subtitle: Text(_formatTime(message.createdAt)),
      trailing: Text(_getRelativeTime(message.createdAt)),
    );
  }
}
```

### 场景 3：文件上传预览

```dart
class FileUploadWidget extends StatefulWidget {
  @override
  _FileUploadWidgetState createState() => _FileUploadWidgetState();
}

class _FileUploadWidgetState extends State<FileUploadWidget> {
  String? _filePath;
  MediaInfo? _mediaInfo;

  Future<void> _pickFile() async {
    // 使用 image_picker 或 file_picker 选择文件
    final FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null && result.files.single.path != null) {
      final path = result.files.single.path!;
      final file = File(path);

      setState(() {
        _filePath = path;
      });

      // 获取文件信息
      final size = await file.length();
      final name = MediaUtils.getFileName(path);
      final type = MediaUtils.getImageType(path);

      setState(() {
        _mediaInfo = MediaInfo(
          path: path,
          name: name,
          type: type,
          size: size,
          createdAt: DateTime.now(),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (_mediaInfo != null) ...[
          Text('文件名: ${_mediaInfo!.name}'),
          Text('文件大小: ${_mediaInfo!.formattedSize}'),
          Text('文件类型: ${_mediaInfo!.type}'),
          if (_mediaInfo!.isImage)
            Image.file(File(_mediaInfo!.path)),
        ],
        ElevatedButton(
          onPressed: _pickFile,
          child: Text('选择文件'),
        ),
      ],
    );
  }
}
```

### 场景 4：金额显示

```dart
class OrderSummaryWidget extends StatelessWidget {
  final Order order;

  const OrderSummaryWidget({required this.order});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('订单金额', style: Theme.of(context).textTheme.titleLarge),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('商品总价:'),
                Text(Formatter.formatMoney(order.productPrice)),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('运费:'),
                Text(Formatter.formatMoney(order.shippingFee)),
              ],
            ),
            Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('订单总额:', style: TextStyle(fontWeight: FontWeight.bold)),
                Text(
                  Formatter.formatMoney(order.totalAmount),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
```

### 场景 5：敏感信息隐藏

```dart
class UserProfileWidget extends StatelessWidget {
  final User user;

  const UserProfileWidget({required this.user});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            ListTile(
              leading: Icon(Icons.phone),
              title: Text('手机号'),
              subtitle: Text(user.phone.hidePhoneNumber ?? ''),
            ),
            ListTile(
              leading: Icon(Icons.email),
              title: Text('邮箱'),
              subtitle: Text(user.email.hideEmail ?? ''),
            ),
            if (user.idCard != null)
              ListTile(
                leading: Icon(Icons.credit_card),
                title: Text('身份证号'),
                subtitle: Text(user.idCard!.hideIdCard ?? ''),
              ),
          ],
        ),
      ),
    );
  }
}
```

---

## API 参考

### StringExtension API

| 方法 | 说明 | 返回类型 |
|------|------|---------|
| `isNullOrEmpty` | 判断是否为空或 null | bool |
| `isNullOrBlank` | 去除首尾空格后判断是否为空 | bool |
| `isPhoneNumber` | 验证是否是手机号 | bool |
| `isEmail` | 验证是否是邮箱 | bool |
| `isNumeric` | 验证是否是纯数字 | bool |
| `isIdCard` | 验证是否是身份证号 | bool |
| `isUrl` | 验证是否是 URL | bool |
| `isIPv4` | 验证是否是 IPv4 地址 | bool |
| `hidePhoneNumber` | 隐藏手机号中间四位 | String? |
| `hideEmail` | 隐藏邮箱 | String? |
| `hideIdCard` | 隐藏身份证号 | String? |
| `capitalize` | 首字母大写 | String? |
| `toIntOrNull()` | 转换为 int | int? |
| `toDoubleOrNull()` | 转换为 double | double? |
| `ellipsis(int)` | 截取字符串并添加省略号 | String? |
| `removeAllWhitespace` | 移除所有空白字符 | String? |
| `containsChinese` | 判断是否包含中文 | bool |
| `toSafeFileName()` | 转换为安全的文件名 | String? |

### DateTimeExtension API

| 方法 | 说明 | 返回类型 |
|------|------|---------|
| `isNull` | 判断是否为 null | bool |
| `isNotNull` | 判断是否不为 null | bool |
| `isToday` | 是否是今天 | bool |
| `isYesterday` | 是否是昨天 | bool |
| `isTomorrow` | 是否是明天 | bool |
| `startOfDay` | 获取当天的开始时间 | DateTime? |
| `endOfDay` | 获取当天的结束时间 | DateTime? |
| `startOfWeek` | 获取当周的第一天 | DateTime? |
| `endOfWeek` | 获取当周的最后一天 | DateTime? |
| `startOfMonth` | 获取当月的第一天 | DateTime? |
| `endOfMonth` | 获取当月的最后一天 | DateTime? |
| `format([pattern])` | 格式化为字符串 | String? |
| `toDateString` | 格式化为日期字符串 | String? |
| `toTimeString` | 格式化为时间字符串 | String? |
| `toDateTimeString` | 格式化为日期时间字符串 | String? |
| `toRelativeTime` | 相对时间描述 | String? |
| `addDays(int)` | 添加天数 | DateTime? |
| `addMonths(int)` | 添加月数 | DateTime? |
| `addYears(int)` | 添加年数 | DateTime? |
| `daysBetween(DateTime?)` | 计算天数差 | int? |

### NumExtension API

| 方法 | 说明 | 返回类型 |
|------|------|---------|
| `isNull` | 判断是否为 null | bool |
| `isNotNull` | 判断是否不为 null | bool |
| `isZero` | 判断是否为 0 | bool |
| `isPositive` | 判断是否大于 0 | bool |
| `isNegative` | 判断是否小于 0 | bool |
| `isBetween(num, num)` | 判断是否在指定范围内 | bool |
| `clamp(num, num)` | 限制在指定范围内 | num? |
| `toFileSize` | 格式化为文件大小字符串 | String? |
| `toCurrency([symbol, decimals])` | 格式化为货币字符串 | String? |
| `toPercent([decimals])` | 格式化为百分比字符串 | String? |
| `toFixedNum(int)` | 保留指定小数位 | num? |
| `toIntOrNull()` | 转换为 int | int? |
| `toDoubleOrNull()` | 转换为 double | double? |

### Validator API

| 方法 | 说明 | 返回类型 |
|------|------|---------|
| `isPhoneNumber(String?)` | 验证手机号 | bool |
| `isEmail(String?)` | 验证邮箱 | bool |
| `isIdCard(String?)` | 验证身份证号 | bool |
| `isUrl(String?)` | 验证 URL | bool |
| `isUsername(String?)` | 验证用户名 | bool |
| `isPassword(String?)` | 验证密码 | bool |
| `isVerificationCode(String?)` | 验证验证码 | bool |
| `isLicensePlate(String?)` | 验证车牌号 | bool |
| `isBankCard(String?)` | 验证银行卡号 | bool |
| `isWeChatId(String?)` | 验证微信号 | bool |
| `isQQ(String?)` | 验证 QQ 号 | bool |
| `isPostalCode(String?)` | 验证邮政编码 | bool |
| `isHexColor(String?)` | 验证颜色值 | bool |
| `isIP(String?)` | 验证 IP 地址 | bool |
| `isLongitude(String?)` | 验证经度 | bool |
| `isLatitude(String?)` | 验证纬度 | bool |
| `isAge(String?)` | 验证年龄 | bool |
| `validate({...})` | 组合验证 | ValidationResult |

### Formatter API

| 方法 | 说明 | 返回类型 |
|------|------|---------|
| `formatPhone(String?)` | 格式化手机号 | String |
| `formatEmail(String?)` | 格式化邮箱 | String |
| `formatIdCard(String?)` | 格式化身份证号 | String |
| `formatBankCard(String?)` | 格式化银行卡号 | String |
| `formatMoney(num?, {...})` | 格式化金额 | String |
| `formatNumberToChinese(int?)` | 格式化数字为中文 | String |
| `formatFileSize(int?)` | 格式化文件大小 | String |
| `formatDuration(int?)` | 格式化时长 | String |
| `formatDateTime(DateTime?, {...})` | 格式化日期时间 | String |
| `formatRelativeTime(DateTime?)` | 格式化相对时间 | String |
| `formatPercent(num?, {...})` | 格式化百分比 | String |
| `formatCoordinate(num?, num?, {...})` | 格式化经纬度 | String |
| `truncate(String?, int)` | 截断文本 | String |
| `highlightKeyword(...)` | 高亮关键词 | String |

### MediaUtils API

| 方法 | 说明 | 返回类型 |
|------|------|---------|
| `getImageType(String)` | 获取图片类型 | String |
| `isImageFile(String)` | 判断是否为图片文件 | bool |
| `isVideoFile(String)` | 判断是否为视频文件 | bool |
| `isAudioFile(String)` | 判断是否为音频文件 | bool |
| `formatFileSize(int)` | 格式化文件大小 | String |
| `getFileName(String)` | 获取文件名 | String |
| `getFileExtension(String)` | 获取文件扩展名 | String |
| `fileExists(String)` | 检查文件是否存在 | Future<bool> |
| `getFileSize(String)` | 获取文件大小 | Future<int> |
| `deleteFile(String)` | 删除文件 | Future<bool> |
| `getFile(String)` | 获取文件对象 | File |
| `createTempFile(...)` | 创建临时文件 | Future<File> |
| `base64Encode(Uint8List)` | Hex 编码 | String |
| `calculateAspectRatio(int, int)` | 计算宽高比 | double |
| `adjustSizeByAspectRatio(...)` | 调整尺寸 | Size |

---

## 最佳实践

### 1. 优先使用扩展方法

```dart
// ✅ 好的做法：使用扩展方法
if (email.isEmail) {
  // ...
}

// ❌ 不好的做法：使用 Validator 静态方法
if (Validator.isEmail(email)) {
  // ...
}
```

### 2. 注意 Null 安全

```dart
String? phone;

// ✅ 好的做法：检查 null
if (phone.isNotNullOrNotEmpty && phone.isPhoneNumber) {
  print(phone.hidePhoneNumber);
}

// ❌ 不好的做法：直接使用
if (phone.isPhoneNumber) {  // 可能返回 null
  // ...
}
```

### 3. 格式化时考虑国际化

```dart
// 对于不同地区，使用不同的货币符号
String currencySymbol = locale == 'zh_CN' ? '¥' : '$';
String formatted = Formatter.formatMoney(amount, symbol: currencySymbol);
```

### 4. 日期格式化使用预定义方法

```dart
// ✅ 好的做法：使用预定义方法
date.toDateString  // '2024-03-15'
date.toTimeString  // '14:30:45'

// ❌ 不好的做法：手动格式化
date.format('yyyy-MM-dd')
```

### 5. 文件操作添加异常处理

```dart
// ✅ 好的做法
try {
  final success = await MediaUtils.deleteFile(filePath);
  if (!success) {
    // 处理删除失败
  }
} catch (e) {
  // 处理异常
}

// ❌ 不好的做法：没有异常处理
await MediaUtils.deleteFile(filePath);
```

---

## 总结

`core_utils` 提供了一套完整的工具函数库：

1. **String 扩展**：验证、格式转换、敏感信息隐藏
2. **DateTime 扩展**：日期判断、计算、格式化
3. **num 扩展**：数值判断、范围限制、格式化
4. **Validator**：全面的数据验证器
5. **Formatter**：统一的数据格式化工具
6. **MediaUtils**：媒体文件处理工具

通过使用这些工具函数，可以大大简化日常开发工作，提高代码的可读性和可维护性。
