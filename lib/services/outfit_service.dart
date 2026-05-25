import '../models/outfit_model.dart';
import '../config/api_config.dart';
import 'api_service.dart';

class OutfitService {
  Future<List<OutfitModel>> getOutfits({String? styleTag, String? search}) async {
    try {
      final params = <String>[];
      if (styleTag != null && styleTag != 'All') params.add('styleTag=$styleTag');
      if (search != null && search.isNotEmpty) params.add('search=${Uri.encodeComponent(search)}');
      final url = params.isEmpty ? ApiConfig.outfits : '${ApiConfig.outfits}?${params.join('&')}';
      final data = await ApiService.get(url);
      return (data['outfits'] as List).map((o) => OutfitModel.fromMap(o)).toList();
    } catch (_) { return _fallbackOutfits(); }
  }

  Future<List<OutfitModel>> getTrendingOutfits() async {
    try {
      final data = await ApiService.get(ApiConfig.trendingOutfits);
      return (data['outfits'] as List).map((o) => OutfitModel.fromMap(o)).toList();
    } catch (_) { return _fallbackOutfits().where((o) => o.isTrending).toList(); }
  }

  Future<List<OutfitModel>> getSavedOutfits() async {
    try {
      final data = await ApiService.get(ApiConfig.savedOutfits);
      return (data['outfits'] as List).map((o) => OutfitModel.fromMap(o)).toList();
    } catch (_) { return []; }
  }

  Future<bool> saveOutfit(String outfitId) async {
    try {
      await ApiService.post(ApiConfig.saveOutfit(outfitId), {});
      return true;
    } catch (_) { return false; }
  }

  Future<bool> unsaveOutfit(String outfitId) async {
    try {
      await ApiService.delete(ApiConfig.saveOutfit(outfitId));
      return true;
    } catch (_) { return false; }
  }

  // Fallback mock data if backend is unreachable
  List<OutfitModel> _fallbackOutfits() => [
    OutfitModel(id:'o1',title:'Parisian Chic',styleTag:'Casual',isTrending:true,
      imageUrl:'https://images.unsplash.com/photo-1529139574466-a303027c1d8b?w=400&q=80',
      items:[OutfitItem(name:'Striped Marinière Top',category:'Tops',brand:'Sandro',price:'\$89'),
             OutfitItem(name:'High-Waist Trousers',category:'Bottoms',brand:'Zara',price:'\$69'),
             OutfitItem(name:'Beige Trench Coat',category:'Outerwear',brand:'Mango',price:'\$129'),
             OutfitItem(name:'Leather Loafers',category:'Shoes',brand:'Massimo Dutti',price:'\$99')]),
    OutfitModel(id:'o2',title:'Summer Boho Dream',styleTag:'Bohemian',isTrending:true,
      imageUrl:'https://images.unsplash.com/photo-1515886657613-9f3515b0c78f?w=400&q=80',
      items:[OutfitItem(name:'Flowy Floral Maxi Dress',category:'Dresses',brand:'Free People',price:'\$118'),
             OutfitItem(name:'Tan Suede Sandals',category:'Shoes',brand:'Steve Madden',price:'\$79'),
             OutfitItem(name:'Wide-Brim Straw Hat',category:'Accessories',price:'\$69')]),
    OutfitModel(id:'o3',title:'Power Office Look',styleTag:'Formal',isTrending:true,
      imageUrl:'https://images.unsplash.com/photo-1580651315530-69c8e0026377?w=400&q=80',
      items:[OutfitItem(name:'Tailored Blazer',category:'Outerwear',brand:'Theory',price:'\$295'),
             OutfitItem(name:'Silk Blouse',category:'Tops',brand:'Equipment',price:'\$178'),
             OutfitItem(name:'Block Heel Pumps',category:'Shoes',brand:'Sam Edelman',price:'\$110')]),
    OutfitModel(id:'o4',title:'Date Night Glam',styleTag:'Evening',isTrending:false,
      imageUrl:'https://images.unsplash.com/photo-1469334031218-e382a71b716b?w=400&q=80',
      items:[OutfitItem(name:'Slip Satin Mini Dress',category:'Dresses',brand:'Réalisation Par',price:'\$195'),
             OutfitItem(name:'Strappy Heeled Sandals',category:'Shoes',brand:'Tony Bianco',price:'\$145')]),
  ];
}
