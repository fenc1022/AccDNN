---
name: cifar10 quantized  Model
caffemodel: cifar10_iter_2000.caffemodel
quantized type: A16C8F4
---
name: quantized.prototxt
caffemodel: cifir10_finetuned.caffemodel
quantized type: A8C8F8
---

This is a very simple model firstly trained on CIFAR10 dataset by 5000 iterations, and quantized to 16 bits activations, 8 bits weights of convlution layer and 4 bits weights of fully connected layer, and retrained by 2000 iterations.
