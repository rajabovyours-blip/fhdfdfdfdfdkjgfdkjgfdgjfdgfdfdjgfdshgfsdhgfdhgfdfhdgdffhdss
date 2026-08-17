import 'dart:io';
import 'package:flutter/material.dart';
import 'package:milliy_metr/core/theme/app_colors_extension.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:milliy_metr/features/reviews/domain/entities/review_entity.dart';
import 'package:milliy_metr/features/reviews/presentation/providers/review_providers.dart';
import 'package:milliy_metr/features/reviews/presentation/widgets/custom_star_rating.dart';
import 'package:milliy_metr/l10n/l10n_extension.dart';

class ReviewComposerSheet extends ConsumerStatefulWidget {
  final String productId;
  final String productName;
  final ReviewEntity? existingReview;

  const ReviewComposerSheet({
    super.key,
    required this.productId,
    required this.productName,
    this.existingReview,
  });

  @override
  ConsumerState<ReviewComposerSheet> createState() =>
      _ReviewComposerSheetState();
}

class _ReviewComposerSheetState extends ConsumerState<ReviewComposerSheet> {
  final TextEditingController _textController = TextEditingController();
  int _rating = 0;
  final List<String> _selectedTemplates = [];
  final List<String> _photos = [];
  bool? _wouldBuyAgain;
  bool _isSubmitting = false;

  final List<String> _templates = [
    'Mahsulot sifati yaxshi',
    'Narxiga arziydi',
    "Yetkazib berish tez bo'ldi",
    'Mahsulot tavsifga mos',
    'Qadoqlanishi yaxshi',
    'Sotuvchi bilan aloqa yaxshi',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.existingReview != null) {
      _rating = widget.existingReview!.rating;
      _textController.text = widget.existingReview!.text ?? '';
      _selectedTemplates.addAll(widget.existingReview!.templates);
      _photos.addAll(widget.existingReview!.photos);
      _wouldBuyAgain = widget.existingReview!.wouldBuyAgain;
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    if (_photos.length >= 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.max5Photos)),
      );
      return;
    }

    final picker = ImagePicker();
    try {
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _photos.add(pickedFile.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.errorLoadingPhoto)),
        );
      }
    }
  }

  Future<void> _submitReview() async {
    if (_rating == 0) return;

    setState(() {
      _isSubmitting = true;
    });

    final newReview = ReviewEntity(
      id: widget.existingReview?.id ?? '',
      productId: widget.productId,
      userId: '', // populated in repository
      userName: '',
      rating: _rating,
      text: _textController.text.trim(),
      photos: _photos,
      templates: _selectedTemplates,
      createdAt: DateTime.now(),
      isVerifiedPurchase: true,
      wouldBuyAgain: _wouldBuyAgain,
    );

    final repository = ref.read(reviewRepositoryProvider);
    final result = await repository.submitReview(newReview);

    result.fold(
      (failure) {
        if (mounted) {
          setState(() {
            _isSubmitting = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(failure.message)),
          );
        }
      },
      (review) {
        // Optimistically add to state
        ref
            .read(productReviewsProvider(widget.productId).notifier)
            .addReview(review);
        if (mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(context.l10n.reviewSubmitted),
              backgroundColor: context.colors.success,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    context.l10n.leaveReview,
                    style: TextStyle(
                      color: context.colors.textHigh,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: context.colors.textHigh),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            Divider(color: context.colors.outline, height: 1),

            Flexible(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product Preview
                    Text(
                      widget.productName,
                      style: TextStyle(
                        color: context.colors.textMedium,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Rating
                    Text(
                      context.l10n.rateProduct,
                      style: TextStyle(
                        color: context.colors.textHigh,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        CustomStarRating(
                          initialRating: _rating,
                          itemSize: 36,
                          onRatingChanged: (rating) {
                            setState(() {
                              _rating = rating;
                            });
                          },
                        ),
                        const SizedBox(width: 12),
                        if (_rating > 0)
                          Text(
                            _getRatingText(context, _rating),
                            style: TextStyle(
                              color: context.colors.primary,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Templates
                    Text(
                      context.l10n.whatDidYouLike,
                      style: TextStyle(
                        color: context.colors.textHigh,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _templates.map((template) {
                        final isSelected =
                            _selectedTemplates.contains(template);
                        return ChoiceChip(
                          label: Text(template),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                _selectedTemplates.add(template);
                              } else {
                                _selectedTemplates.remove(template);
                              }
                            });
                          },
                          backgroundColor: context.colors.background,
                          selectedColor:
                              context.colors.primary.withValues(alpha: 0.2),
                          labelStyle: TextStyle(
                            color: isSelected
                                ? context.colors.primary
                                : context.colors.textMedium,
                            fontSize: 12,
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 4, vertical: 0,),
                          side: BorderSide(
                            color: isSelected
                                ? context.colors.primary
                                : context.colors.outline,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),

                    // Would buy again
                    Text(
                      context.l10n.wouldYouBuyAgain,
                      style: TextStyle(
                        color: context.colors.textHigh,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _wouldBuyAgain = true),
                            child: Container(
                              height: 40,
                              decoration: BoxDecoration(
                                color: _wouldBuyAgain == true
                                    ? context.colors.success.withValues(alpha: 0.2)
                                    : context.colors.background,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: _wouldBuyAgain == true
                                      ? context.colors.success
                                      : context.colors.outline,
                                ),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                context.l10n.yes,
                                style: TextStyle(
                                  color: _wouldBuyAgain == true
                                      ? context.colors.success
                                      : context.colors.textMedium,
                                  fontWeight: _wouldBuyAgain == true
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _wouldBuyAgain = false),
                            child: Container(
                              height: 40,
                              decoration: BoxDecoration(
                                color: _wouldBuyAgain == false
                                    ? context.colors.danger.withValues(alpha: 0.2)
                                    : context.colors.background,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: _wouldBuyAgain == false
                                      ? context.colors.danger
                                      : context.colors.outline,
                                ),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                context.l10n.no,
                                style: TextStyle(
                                  color: _wouldBuyAgain == false
                                      ? context.colors.danger
                                      : context.colors.textMedium,
                                  fontWeight: _wouldBuyAgain == false
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Text Field
                    Text(
                      context.l10n.yourReview,
                      style: TextStyle(
                        color: context.colors.textHigh,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _textController,
                      style: TextStyle(
                        color: context.colors.textHigh,
                        fontSize: 14,
                      ),
                      maxLength: 1000,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: context.l10n.writeReviewHint,
                        hintStyle: TextStyle(
                          color: context.colors.textMedium,
                          fontSize: 14,
                        ),
                        filled: true,
                        fillColor: context.colors.background,
                        contentPadding: const EdgeInsets.all(12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: context.colors.outline),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: context.colors.outline),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: context.colors.primary),
                        ),
                        counterStyle: TextStyle(
                          color: context.colors.textMedium,
                          fontSize: 12,
                        ),
                      ),
                      onChanged: (text) => setState(() {}),
                    ),
                    const SizedBox(height: 12),

                    // Photos
                    Row(
                      children: [
                        Text(
                          context.l10n.photos,
                          style: TextStyle(
                            color: context.colors.textHigh,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '${_photos.length}/5',
                          style: TextStyle(
                            color: context.colors.textMedium,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          if (_photos.length < 5)
                            GestureDetector(
                              onTap: _pickImage,
                              child: Container(
                                width: 64,
                                height: 64,
                                margin: const EdgeInsets.only(right: 12),
                                decoration: BoxDecoration(
                                  color: context.colors.background,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: context.colors.outline,
                                    style: BorderStyle.solid,
                                  ),
                                ),
                                child: Icon(
                                  Icons.add_photo_alternate_outlined,
                                  color: context.colors.textMedium,
                                  size: 24,
                                ),
                              ),
                            ),
                          ..._photos.asMap().entries.map((entry) {
                            final index = entry.key;
                            final path = entry.value;
                            return Container(
                              width: 64,
                              height: 64,
                              margin: const EdgeInsets.only(right: 12),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border:
                                    Border.all(color: context.colors.outline),
                                image: DecorationImage(
                                  image: FileImage(File(path)),
                                  fit: BoxFit.cover,
                                ),
                              ),
                              child: Align(
                                alignment: Alignment.topRight,
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _photos.removeAt(index);
                                    });
                                  },
                                  child: Container(
                                    margin: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: context.colors.surfaceVariant
                                          .withValues(alpha: 0.7),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.close,
                                      color: context.colors.textHigh,
                                      size: 16,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // Submit Button
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.colors.primary,
                    foregroundColor: context.colors.textHigh,
                    disabledBackgroundColor: context.colors.outline,
                    disabledForegroundColor: context.colors.textMedium,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed:
                      (_rating == 0 || _isSubmitting) ? null : _submitReview,
                  child: _isSubmitting
                      ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: context.colors.textHigh,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          context.l10n.submitReview,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getRatingText(BuildContext context, int rating) {
    switch (rating) {
      case 1:
        return context.l10n.ratingVeryBad;
      case 2:
        return context.l10n.ratingBad;
      case 3:
        return context.l10n.ratingAverage;
      case 4:
        return context.l10n.ratingGood;
      case 5:
        return context.l10n.ratingExcellent;
      default:
        return '';
    }
  }
}

void showReviewComposer(
  BuildContext context,
  String productId,
  String productName, {
  ReviewEntity? existingReview,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => ReviewComposerSheet(
      productId: productId,
      productName: productName,
      existingReview: existingReview,
    ),
  );
}
