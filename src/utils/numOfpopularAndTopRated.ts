export const numOfpopularProduct = (num: number) =>
  num * 0.4 > 20 ? Math.floor(num * 0.4) : num > 20 ? 20 : num;

export const numOfTopRatedProduct = (num: number) =>
  num / 2 > 20 ? Math.floor(num / 2) : num > 20 ? 20 : num;
