import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DiscountCodesPage extends StatefulWidget {
  final String userId;

  const DiscountCodesPage({Key? key, required this.userId}) : super(key: key);

  @override
  State<DiscountCodesPage> createState() => _DiscountCodesPageState();
}

class _DiscountCodesPageState extends State<DiscountCodesPage> {
  final SupabaseClient supabase = Supabase.instance.client;
  List<dynamic> discountCodes = [];
  bool isLoading = true;
  bool isFetchingMore = false;
  int currentPage = 0;
  final int pageSize = 7;
  bool hasMore = true;

  @override
  void initState() {
    super.initState();
    fetchDiscountCodes();
  }

  Future<void> fetchDiscountCodes({bool loadMore = false}) async {
    if (loadMore && isFetchingMore) return;
    try {
      if (!loadMore) {
        setState(() {
          isLoading = true;
        });
      } else {
        setState(() {
          isFetchingMore = true;
        });
      }

      final response = await supabase
          .from('discount_codes')
          .select()
          .eq('user_id', widget.userId)
          .order('created_at', ascending: false)
          .range(currentPage * pageSize, (currentPage + 1) * pageSize - 1);

      if (response != null && response.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            setState(() {
              discountCodes.addAll(response);
              currentPage++;
              if (response.length < pageSize) {
                hasMore = false;
              }
            });
          }
        });
      } else {
        setState(() {
          hasMore = false;
        });
      }
    } catch (error) {
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
          isFetchingMore = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title:
            const Text('Discount Codes', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xff2C9CEE),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () async {
                setState(() {
                  discountCodes.clear();
                  currentPage = 0;
                  hasMore = true;
                });
                await fetchDiscountCodes();
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: discountCodes.length + (hasMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == discountCodes.length) {
                    if (isFetchingMore) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (hasMore) {
                      Future.microtask(
                          () => fetchDiscountCodes(loadMore: true));
                      return const Center(child: CircularProgressIndicator());
                    } else {
                      return const SizedBox.shrink();
                    }
                  }

                  final code = discountCodes[index];
                  return Card(
                    elevation: 4,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    child: ListTile(
                      leading: Icon(
                        code['is_used'] ? Icons.check_circle : Icons.discount,
                        color: code['is_used']
                            ? Colors.green
                            : const Color(0xff2C9CEE),
                      ),
                      title: Text(
                        code['code'] ?? 'Unknown Code',
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Discount: ${code['discount_percentage'] ?? 0}%',
                            style: const TextStyle(fontSize: 14),
                          ),
                          Text(
                            'Used: ${code['is_used'] ? 'Yes' : 'No'}',
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
