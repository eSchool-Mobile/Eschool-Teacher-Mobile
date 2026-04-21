import 'package:eschool_saas_staff/cubits/announcement/deleteAnnouncementCubit.dart';
import 'package:eschool_saas_staff/ui/widgets/customCircularProgressIndicator.dart';
import 'package:eschool_saas_staff/ui/widgets/customTextButton.dart';
import 'package:eschool_saas_staff/ui/widgets/customTextContainer.dart';
import 'package:eschool_saas_staff/utils/labelKeys.dart';
import 'package:eschool_saas_staff/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

class DeleteAnnouncementDialog extends StatelessWidget {
  final int announcementId;
  const DeleteAnnouncementDialog({super.key, required this.announcementId});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: const CustomTextContainer(
        textKey: areYouSureToDeleteKey,
      ),
      actions: [
        BlocConsumer<DeleteAnnouncementCubit, DeleteAnnouncementState>(
          listener: (context, state) {
            if (state is DeleteAnnouncementSuccess) {
              Get.back(result: announcementId);
                ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center, 
                    children: [
                    Icon(Icons.check_circle, color: Colors.white),
                    SizedBox(width: 12),
                    Text(
                      'Pengumuman dihapus!',
                      style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      ),
                    ),
                    ],
                  ),
                  ),
                  backgroundColor: Colors.green.shade400,
                  duration: const Duration(seconds: 2),
                  behavior: SnackBarBehavior.floating,
                  margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 4,
                ),
                );
            } else if (state is DeleteAnnouncementFailure) {
              Get.back();
              Utils.showSnackBar(message: state.errorMessage, context: context);
            }
          },
          builder: (context, state) {
            return state is DeleteAnnouncementInProgress
                ? PopScope(
                    canPop: false,
                    child: CustomCircularProgressIndicator(
                      indicatorColor: Theme.of(context).colorScheme.primary,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      CustomTextButton(
                          buttonTextKey: yesKey,
                          onTapButton: () {
                            context
                                .read<DeleteAnnouncementCubit>()
                                .deleteAnnouncement(
                                    announcementId: announcementId);
                          }),
                      const SizedBox(
                        width: 25.0,
                      ),
                      CustomTextButton(
                          buttonTextKey: noKey,
                          onTapButton: () {
                            Get.back();
                          }),
                    ],
                  );
          },
        )
      ],
    );
  }
}
