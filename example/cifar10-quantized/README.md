---
name: quantized_A16C8F4.prototxt
caffemodel: cifar10_iter_2000.caffemodel
quantized type: A16C8F4

name: quantized_A16C16F16.prototxt
caffemodel: cifir10_A16C16F16.caffemodel
quantized type: A16C16F16
---

This is a very simple model firstly trained on CIFAR10 dataset by 5000 iterations, and quantized to 16 bits activations, 8 bits weights of convlution layer and 4 bits weights of fully connected layer, and retrained by 2000 iterations.
