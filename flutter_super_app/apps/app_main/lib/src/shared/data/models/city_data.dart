library;

/// 省份城市数据模型
class ProvinceModel {
  final String name;
  final List<String> cities;

  const ProvinceModel({
    required this.name,
    required this.cities,
  });
}

/// 中国省份城市数据（部分主要省市）
///
/// 完整数据可以后期从后端获取或使用完整的省市数据包
class ChinaCityData {
  static const List<ProvinceModel> provinces = [
    ProvinceModel(
      name: '北京',
      cities: ['东城区', '西城区', '朝阳区', '海淀区', '丰台区', '石景山区', '通州区', '顺义区', '大兴区', '昌平区'],
    ),
    ProvinceModel(
      name: '上海',
      cities: ['黄浦区', '徐汇区', '长宁区', '静安区', '普陀区', '虹口区', '杨浦区', '浦东新区', '闵行区', '宝山区'],
    ),
    ProvinceModel(
      name: '广东',
      cities: ['广州', '深圳', '珠海', '汕头', '佛山', '韶关', '湛江', '肇庆', '江门', '茂名'],
    ),
    ProvinceModel(
      name: '浙江',
      cities: ['杭州', '宁波', '温州', '嘉兴', '湖州', '绍兴', '金华', '衢州', '舟山', '台州'],
    ),
    ProvinceModel(
      name: '江苏',
      cities: ['南京', '无锡', '徐州', '常州', '苏州', '南通', '连云港', '淮安', '盐城', '扬州'],
    ),
    ProvinceModel(
      name: '四川',
      cities: ['成都', '自贡', '攀枝花', '泸州', '德阳', '绵阳', '广元', '遂宁', '内江', '乐山'],
    ),
    ProvinceModel(
      name: '湖北',
      cities: ['武汉', '黄石', '十堰', '宜昌', '襄阳', '鄂州', '荆门', '孝感', '荆州', '黄冈'],
    ),
    ProvinceModel(
      name: '陕西',
      cities: ['西安', '铜川', '宝鸡', '咸阳', '渭南', '延安', '汉中', '榆林', '安康', '商洛'],
    ),
    ProvinceModel(
      name: '福建',
      cities: ['福州', '厦门', '莆田', '三明', '泉州', '漳州', '南平', '龙岩', '宁德'],
    ),
    ProvinceModel(
      name: '山东',
      cities: ['济南', '青岛', '淄博', '枣庄', '东营', '烟台', '潍坊', '济宁', '泰安', '威海'],
    ),
    ProvinceModel(
      name: '河南',
      cities: ['郑州', '开封', '洛阳', '平顶山', '安阳', '鹤壁', '新乡', '焦作', '濮阳', '许昌'],
    ),
    ProvinceModel(
      name: '天津',
      cities: ['和平区', '河东区', '河西区', '南开区', '河北区', '红桥区', '东丽区', '西青区', '津南区', '北辰区'],
    ),
    ProvinceModel(
      name: '重庆',
      cities: ['万州区', '涪陵区', '渝中区', '大渡口区', '江北区', '沙坪坝区', '九龙坡区', '南岸区', '北碚区', '渝北区'],
    ),
    ProvinceModel(
      name: '湖南',
      cities: ['长沙', '株洲', '湘潭', '衡阳', '邵阳', '岳阳', '常德', '张家界', '益阳', '郴州'],
    ),
    ProvinceModel(
      name: '安徽',
      cities: ['合肥', '芜湖', '蚌埠', '淮南', '马鞍山', '淮北', '铜陵', '安庆', '黄山', '滁州'],
    ),
  ];

  /// 根据省份名称获取城市列表
  static List<String> getCitiesByProvince(String provinceName) {
    final province = provinces.firstWhere(
      (p) => p.name == provinceName,
      orElse: () => ProvinceModel(name: provinceName, cities: []),
    );
    return province.cities;
  }
}
