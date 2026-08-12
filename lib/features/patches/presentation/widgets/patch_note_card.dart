import 'package:flutter/material.dart';

class PatchNoteCard extends StatelessWidget {
  const PatchNoteCard({
    super.key,
    required this.number,
    required this.version,
    required this.releaseDate,
    this.isEditMode = false,
    this.onPressed,
  });

  final int number;
  final String version;
  final String releaseDate;
  final bool isEditMode;

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,

      margin: const EdgeInsets.only(
        bottom: 10,
      ),

      child: Material(
        color: Colors.transparent,

        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          hoverColor: Colors.black12,
          focusColor: Colors.black12,

          child: Ink(
            width: double.infinity,

            padding:
            const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 8,
            ),

            decoration: BoxDecoration(
              gradient:
              const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,

                colors: [
                  Color(0xFF3F372C),
                  Color(0xFF8E805D),
                ],
              ),

              borderRadius: BorderRadius.circular(12),

              boxShadow: const [
                BoxShadow(
                  color: Colors.black38,
                  blurRadius: 4,
                  offset: Offset(2, 3),
                ),
              ],
            ),

            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,

              children: [

                Container(
                  width: 48,
                  height: 70,

                  alignment: Alignment.center,

                  decoration: BoxDecoration(
                    color: const Color(0xFF443526),
                    borderRadius: BorderRadius.circular(6),
                  ),

                  child: Text(
                    '$number.',

                    style:
                    const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      fontFamily: 'JosefinSlab',
                    ),
                  ),
                ),

                const SizedBox(
                  width: 8,
                ),

                Expanded(
                  child:
                  Transform.translate(
                    offset:
                    const Offset(0, -7),

                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment
                          .start,

                      children: [

                        Text(
                          version,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          softWrap: false,

                          style:
                          const TextStyle(
                            fontSize: 36,
                            color: Colors.white,
                            fontFamily: 'Jomolhari',
                          ),
                        ),

                        const SizedBox(
                          height: 2,
                        ),

                        RichText(
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          text: TextSpan(
                            children: [

                              TextSpan(
                                text:
                                'Release date: ',

                                style:
                                const TextStyle(
                                  fontSize: 22,
                                  color: Colors.black,
                                  fontFamily: 'JosefinSlab',
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              TextSpan(
                                text: releaseDate,

                                style:
                                const TextStyle(
                                  fontSize: 22,
                                  color: Colors.black,
                                  fontFamily: 'JosefinSlab',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                Icon(
                  isEditMode ? Icons.edit_outlined : Icons.chevron_right,
                  color: Colors.black,
                  size: 30,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
