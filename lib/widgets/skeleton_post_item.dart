import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class SkeletonPostItem extends StatelessWidget {
  const SkeletonPostItem({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Shimmer.fromColors(
        baseColor: Colors.grey[800]!,
        highlightColor: Colors.grey[600]!,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.grey[850],
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.grey[700],
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 80,
                          height: 14,
                          color: Colors.grey[700],
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: 120,
                          height: 10,
                          color: Colors.grey[700],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                height: 16,
                color: Colors.grey[700],
              ),
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                height: 120,
                color: Colors.grey[700],
              ),
              const SizedBox(height: 14),
              Row(
                children: List.generate(4, (i) => Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: Colors.grey[700],
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                )),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 