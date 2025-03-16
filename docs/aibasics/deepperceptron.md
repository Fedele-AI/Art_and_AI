<!-- Written by Alex Jenkins and Dr. Francesco Fedele for CEE4803/LMC4813 - (c) Georgia Tech, Spring 2025 -->

<div align="center">

# Deep Perceptron

</div>

### Limitations of the Linear Perceptron
One key limitation of the perceptron is that it can only model linearly separable functions. This means that it fails to correctly classify the XOR gate, which is not linearly separable.

### Multi-Layer Perceptron (MLP) for XOR Gate
To solve the XOR problem, we use a Multi-Layer Perceptron (MLP) with two layers:

$$ h_1 = \sigma(w_{11} x_1 + w_{12} x_2 + b_1) $$

$$ h_2 = \sigma(w_{21} x_1 + w_{22} x_2 + b_2) $$

$$ y = \sigma(w_3 h_1 + w_4 h_2 + b_3) $$

where $h_1$ and $h_2$ are hidden layer neurons, and $y$ is the final output.

### Training the MLP Using Least Squares
To train the MLP, we define the error function:

$$ E = \sum_{i=1}^{N} (y_i - \hat{y}_i)^2, $$

where $y_i$ is the predicted output to an input $\hat{x}_i$, and $\hat{y}_i$ the expected output. The data are given as pairs $(\hat{x}_i,\hat{y}_i)$, $i=1,\dots N$. The weights are updated using backpropagation:

$$ w_{ij} = w_{ij} + \eta \frac{\partial E}{\partial w_{ij}} $$

$$ b_j = b_j + \eta \frac{\partial E}{\partial b_j}, \quad w_j = w_j + \eta \frac{\partial E}{\partial w_j} $$

where the gradients are computed using the chain rule, and $\eta$ is the learning rate. By iterating this process, the MLP can successfully learn the XOR function.

## Remark
A **deep perceptron**, commonly referred to as a **deep neural network (DNN)** or **multi-layer perceptron (MLP)**, is an extension of the basic perceptron that can learn complex patterns by stacking multiple layers of neurons. Unlike a single-layer perceptron, which can only classify linearly separable data, a deep perceptron has multiple hidden layers between the input and output layers, allowing it to learn intricate relationships and solve more complex problems.

Each neuron in a deep perceptron applies a weighted sum to its inputs, passes the result through a non-linear activation function (like ReLU or sigmoid), and sends the output to the next layer. The network is trained using **backpropagation**, an algorithm that adjusts the weights by computing the error at the output and propagating it backward through the layers to improve accuracy.

To explain it simply, imagine a deep perceptron like a **team of experts** passing along information. The first layer detects simple patterns (like edges in an image), the next layer combines those patterns into shapes, and deeper layers recognize objects like faces or cars. The more layers the network has, the more abstract and high-level features it can learn, making deep perceptrons powerful tools for image recognition, speech processing, and even decision-making tasks.

## Video Explanations

### Video 1. A Deep Perceptron For The XOR gate
[![Watch the video](https://img.youtube.com/vi/sW-G388ra8k/0.jpg)](https://youtu.be/sW-G388ra8k)

### Video 2. Python Implementation Of A Deep Perceptron for XOR Gates
[![Watch the video](https://img.youtube.com/vi/oeVPtmNA8Z4/0.jpg)](https://youtu.be/oeVPtmNA8Z4)

