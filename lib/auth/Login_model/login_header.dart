import 'package:flutter/material.dart';

class LoginHeader extends StatelessWidget {
  const LoginHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.30,
      decoration: const BoxDecoration(
        color: Color(0xFF0077B6),
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(60)),
      ),
      alignment: Alignment.center,
      child: const Icon(
        Icons.account_balance_wallet_outlined,
        color: Colors.white,
        size: 64,
      ),
    );
  }
}
