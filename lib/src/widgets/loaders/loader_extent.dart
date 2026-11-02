/// Size handling shared by the built-in loaders.
library;

/// The extent a loader of [size] is laid out with: [size] itself, or 0
/// (draw nothing) when it is negative or NaN.
double loaderExtent(double size) => size > 0 ? size : 0;
