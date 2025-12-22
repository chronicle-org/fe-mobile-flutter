import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill_delta_from_html/flutter_quill_delta_from_html.dart';
import 'package:vsc_quill_delta_to_html/vsc_quill_delta_to_html.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'dart:convert';
import '../models/post.dart';
import '../services/post_service.dart';
import '../services/api_service.dart';

class EditPostScreen extends StatefulWidget {
  final Post? post; // If null, we are creating a new post

  const EditPostScreen({super.key, this.post});

  @override
  State<EditPostScreen> createState() => _EditPostScreenState();
}

class _EditPostScreenState extends State<EditPostScreen> {
  late QuillController _titleController;
  late QuillController _subtitleController;
  late QuillController _contentController;
  late QuillController _activeController; // Tracks which editor is focused
  late final FocusNode _titleFocusNode;
  late final FocusNode _subtitleFocusNode;
  late final FocusNode _contentFocusNode;
  late final ScrollController _scrollController;
  final ImagePicker _picker = ImagePicker();
  String _thumbnailUrl = '';
  bool _isSubmitting = false;
  bool _isUploadingThumbnail = false;

  @override
  void initState() {
    super.initState();
    _titleFocusNode = FocusNode();
    _subtitleFocusNode = FocusNode();
    _contentFocusNode = FocusNode();
    _scrollController = ScrollController();
    _initializeQuillControllers();
    _setupFocusListeners();
    if (widget.post != null) {
      _thumbnailUrl = widget.post!.thumbnailUrl;
    }
  }

  void _setupFocusListeners() {
    // Listen to focus changes and update active controller
    _titleFocusNode.addListener(() {
      if (_titleFocusNode.hasFocus) {
        setState(() {
          _activeController = _titleController;
        });
      }
    });

    _subtitleFocusNode.addListener(() {
      if (_subtitleFocusNode.hasFocus) {
        setState(() {
          _activeController = _subtitleController;
        });
      }
    });

    _contentFocusNode.addListener(() {
      if (_contentFocusNode.hasFocus) {
        setState(() {
          _activeController = _contentController;
        });
      }
    });
  }

  void _initializeQuillControllers() {
    // Initialize title controller
    if (widget.post != null && widget.post!.title.isNotEmpty) {
      try {
        final titleDelta = HtmlToDelta().convert(widget.post!.title);
        _titleController = QuillController(
          document: Document.fromDelta(titleDelta),
          selection: const TextSelection.collapsed(offset: 0),
        );
      } catch (e) {
        _titleController = QuillController(
          document: Document()
            ..insert(0, _extractTextFromHtml(widget.post!.title)),
          selection: const TextSelection.collapsed(offset: 0),
        );
      }
    } else {
      _titleController = QuillController.basic();
    }

    // Initialize subtitle controller
    if (widget.post != null && widget.post!.subTitle.isNotEmpty) {
      try {
        final subtitleDelta = HtmlToDelta().convert(widget.post!.subTitle);
        _subtitleController = QuillController(
          document: Document.fromDelta(subtitleDelta),
          selection: const TextSelection.collapsed(offset: 0),
        );
      } catch (e) {
        _subtitleController = QuillController(
          document: Document()
            ..insert(0, _extractTextFromHtml(widget.post!.subTitle)),
          selection: const TextSelection.collapsed(offset: 0),
        );
      }
    } else {
      _subtitleController = QuillController.basic();
    }

    // Initialize content controller
    if (widget.post != null && widget.post!.content.isNotEmpty) {
      try {
        final contentDelta = HtmlToDelta().convert(widget.post!.content);
        _contentController = QuillController(
          document: Document.fromDelta(contentDelta),
          selection: const TextSelection.collapsed(offset: 0),
        );
      } catch (e) {
        _contentController = QuillController(
          document: Document()
            ..insert(0, _extractTextFromHtml(widget.post!.content)),
          selection: const TextSelection.collapsed(offset: 0),
        );
      }
    } else {
      _contentController = QuillController.basic();
    }

    // Set initial active controller to content
    _activeController = _contentController;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _subtitleController.dispose();
    _contentController.dispose();
    _titleFocusNode.dispose();
    _subtitleFocusNode.dispose();
    _contentFocusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  String _extractTextFromHtml(String html) {
    return html.replaceAll(RegExp(r'<[^>]*>'), '');
  }

  Future<void> _pickAndUploadThumbnail() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;

    setState(() {
      _isUploadingThumbnail = true;
    });

    try {
      final uri = Uri.parse('${ApiService.baseUrl}/file?type=thumbnail');
      final request = http.MultipartRequest('POST', uri);

      request.headers.addAll(ApiService.headers);
      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          image.path,
          contentType: MediaType('image', 'jpeg'),
        ),
      );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 201 || response.statusCode == 200) {
        final body = jsonDecode(response.body);
        setState(() {
          _thumbnailUrl = body['content']['url'];
        });
      } else {
        throw Exception('Failed to upload image: ${response.statusCode}');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Upload failed: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploadingThumbnail = false;
        });
      }
    }
  }

  Future<void> _submit() async {
    // Convert title to HTML
    final titleDeltaJson = _titleController.document.toDelta().toJson();
    final titleConverter = QuillDeltaToHtmlConverter(
      List<Map<String, dynamic>>.from(titleDeltaJson),
      ConverterOptions(),
    );
    final titleHtml = titleConverter.convert();

    // Convert subtitle to HTML
    final subtitleDeltaJson = _subtitleController.document.toDelta().toJson();
    final subtitleConverter = QuillDeltaToHtmlConverter(
      List<Map<String, dynamic>>.from(subtitleDeltaJson),
      ConverterOptions(),
    );
    final subtitleHtml = subtitleConverter.convert();

    // Convert content to HTML
    final contentDeltaJson = _contentController.document.toDelta().toJson();
    final contentConverter = QuillDeltaToHtmlConverter(
      List<Map<String, dynamic>>.from(contentDeltaJson),
      ConverterOptions(),
    );
    final contentHtml = contentConverter.convert();

    // Get plain text for validation
    final titleText = _titleController.document.toPlainText().trim();

    if (titleText.isEmpty || contentHtml.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Title and content are required')),
        );
      }
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final payload = {
        'title': titleHtml,
        'sub_title': subtitleHtml,
        'content': contentHtml,
        'thumbnail_url': _thumbnailUrl,
      };

      if (widget.post == null) {
        await PostService.createPost(payload);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Post created successfully!')),
          );
          Navigator.pop(context, true);
        }
      } else {
        await PostService.updatePost(widget.post!.id, payload);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Post updated successfully!')),
          );
          Navigator.pop(context, true);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.post == null ? 'Create Post' : 'Edit Post'),
        actions: [
          if (_isSubmitting)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else
            TextButton(
              onPressed: _submit,
              child: const Text(
                'Publish',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                children: [
                  // Title Editor
                  QuillEditor(
                    controller: _titleController,
                    scrollController: ScrollController(),
                    focusNode: _titleFocusNode,
                    config: QuillEditorConfig(
                      placeholder: 'Title',
                      padding: EdgeInsets.zero,
                      customStyles: DefaultStyles(
                        paragraph: DefaultTextBlockStyle(
                          Theme.of(context).textTheme.headlineMedium!.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          const HorizontalSpacing(0, 0),
                          const VerticalSpacing(0, 0),
                          const VerticalSpacing(0, 0),
                          null,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Subtitle Editor
                  QuillEditor(
                    controller: _subtitleController,
                    scrollController: ScrollController(),
                    focusNode: _subtitleFocusNode,
                    config: QuillEditorConfig(
                      placeholder: 'Subtitle (optional)',
                      padding: EdgeInsets.zero,
                      customStyles: DefaultStyles(
                        paragraph: DefaultTextBlockStyle(
                          Theme.of(
                            context,
                          ).textTheme.titleMedium!.copyWith(color: Colors.grey),
                          const HorizontalSpacing(0, 0),
                          const VerticalSpacing(0, 0),
                          const VerticalSpacing(0, 0),
                          null,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildThumbnailSelector(),
                  const SizedBox(height: 16),
                  const Divider(),
                  // Content Editor
                  QuillEditor(
                    controller: _contentController,
                    scrollController: _scrollController,
                    focusNode: _contentFocusNode,
                    config: const QuillEditorConfig(
                      placeholder: 'Tell your story...',
                      padding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).canvasColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: QuillSimpleToolbar(
              controller: _activeController,
              config: const QuillSimpleToolbarConfig(
                multiRowsDisplay: false,
                showFontFamily: false,
                showFontSize: false,
                showSubscript: false,
                showSuperscript: false,
                showSmallButton: true,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThumbnailSelector() {
    return GestureDetector(
      onTap: _isUploadingThumbnail ? null : _pickAndUploadThumbnail,
      child: Container(
        height: 120,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
          image: _thumbnailUrl.isNotEmpty
              ? DecorationImage(
                  image: NetworkImage(_thumbnailUrl),
                  fit: BoxFit.cover,
                )
              : null,
        ),
        child: _isUploadingThumbnail
            ? const Center(child: CircularProgressIndicator())
            : _thumbnailUrl.isEmpty
            ? const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_a_photo, size: 40, color: Colors.grey),
                  SizedBox(height: 8),
                  Text('Add Thumbnail', style: TextStyle(color: Colors.grey)),
                ],
              )
            : null,
      ),
    );
  }
}
