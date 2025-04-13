import 'package:flutter/material.dart';

class SignUpHeader extends StatelessWidget {
  const SignUpHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.3,
      decoration: const BoxDecoration(
        color: Color(0xFF0077B6),
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(80)),
      ),
      alignment: Alignment.center,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.account_balance_wallet_outlined,
          color: Color(0xFF0077B6),
          size: 40,
        ),
      ),
    );
  }
}
