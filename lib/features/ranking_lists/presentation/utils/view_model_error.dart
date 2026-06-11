String messageFromViewModelError(Object error) {
  if (error is StateError) {
    return error.message;
  }

  return 'Something went wrong. Please try again.';
}
