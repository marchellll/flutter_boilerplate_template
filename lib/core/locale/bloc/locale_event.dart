import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

abstract class LocaleEvent extends Equatable {
  const LocaleEvent();

  @override
  List<Object?> get props => [];
}

class LoadLocaleEvent extends LocaleEvent {
  const LoadLocaleEvent();
}

class ChangeLocaleEvent extends LocaleEvent {
  final Locale locale;
  
  const ChangeLocaleEvent(this.locale);

  @override
  List<Object?> get props => [locale];
}
