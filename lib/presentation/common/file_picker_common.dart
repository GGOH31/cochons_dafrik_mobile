import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/themes/app_color.dart';

/// Un sélecteur de fichier réutilisable pour Cochons d'Afrik.
/// S'intègre avec FormField pour la validation automatique dans les formulaires.
class CdaFilePicker extends FormField<PlatformFile?> {
  final String title;
  final String? subtitle;
  final List<String>? allowedExtensions;
  final FileType fileType;
  final ValueChanged<PlatformFile?>? onFileSelected;

  CdaFilePicker({
    super.key,
    required this.title,
    this.subtitle,
    this.allowedExtensions,
    this.fileType = FileType.any,
    this.onFileSelected,
    super.validator,
    super.initialValue,
  }) : super(
          builder: (FormFieldState<PlatformFile?> state) {
            final pickedFile = state.value;
            final hasError = state.hasError;
            
            Future<void> pickFile() async {
              try {
                final result = await FilePicker.pickFiles(
                  type: fileType,
                  allowedExtensions: allowedExtensions,
                );
                if (result != null && result.files.isNotEmpty) {
                  final file = result.files.first;
                  state.didChange(file);
                  if (onFileSelected != null) {
                    onFileSelected(file);
                  }
                }
              } catch (e) {
                debugPrint('Erreur lors du choix du fichier : $e');
              }
            }

            void clearFile() {
              state.didChange(null);
              if (onFileSelected != null) {
                onFileSelected(null);
              }
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.fredoka(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: CdaColors.encre,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: GoogleFonts.nunito(
                      fontSize: 12,
                      color: CdaColors.gris,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: pickedFile == null ? pickFile : null,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: hasError
                            ? CdaColors.rouge
                            : (pickedFile != null ? CdaColors.vertForet : CdaColors.ligne),
                        width: pickedFile != null ? 2.0 : 1.5,
                      ),
                    ),
                    child: pickedFile == null
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.cloud_upload_outlined,
                                color: CdaColors.vertForet,
                                size: 28,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                "Choisir un fichier",
                                style: GoogleFonts.nunito(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: CdaColors.vertForet,
                                ),
                              ),
                            ],
                          )
                        : Row(
                            children: [
                              const Icon(
                                Icons.insert_drive_file_outlined,
                                color: CdaColors.vertForet,
                                size: 28,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      pickedFile.name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.nunito(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: CdaColors.encre,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      _formatBytes(pickedFile.size),
                                      style: GoogleFonts.nunito(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                        color: CdaColors.gris,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.cancel,
                                  color: CdaColors.rouge,
                                ),
                                onPressed: clearFile,
                              ),
                            ],
                          ),
                  ),
                ),
                if (hasError) ...[
                  const SizedBox(height: 6),
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Text(
                      state.errorText ?? '',
                      style: GoogleFonts.nunito(
                        fontSize: 12,
                        color: CdaColors.rouge,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ],
            );
          },
        );

  static String _formatBytes(int bytes) {
    if (bytes <= 0) return "0 B";
    const sizes = ["B", "KB", "MB", "GB"];
    var i = 0;
    double size = bytes.toDouble();
    while (size >= 1024 && i < sizes.length - 1) {
      size /= 1024;
      i++;
    }
    return "${size.toStringAsFixed(1)} ${sizes[i]}";
  }
}
