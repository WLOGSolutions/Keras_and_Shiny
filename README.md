# Keras and Shiny

This is a showcase based on the tutorial presented at ML@Enterprise Forum 2018 in Warsaw. It is intended to show how you can get what's best in R (e.g. [Shiny applications](https://shiny.rstudio.com/)) and in Python (e.g. [Keras framework](https://keras.io/)) and combine it to get a ready-to-deploy package thanks to [R Suite toolset](https://rsuite.io/).

Going through this instruction, you should be able to:   

1. Recreate development environment,   
2. Build a CNN model for digit reconition,   
3. Run a web app that uses created model to recognize new examples,   
4. Create a deployment package ready for production.  

The instruction shows how to recreate development environment starting from cloning this repository. If you would like to see how such solution is built from scratch or just see the result (the deployment package) please go to the bottom of this document where you can find adequate links.

## Preliminary requirements

This particular case was developed and built for Windows x64, however all tools are also available for Linux and MacOS.

Tools used for development (with versions):

* [R (for Windows)](https://cran.r-project.org/bin/windows/base/) [3.5.1]   
* [RStudio](https://www.rstudio.com/products/rstudio/download/) [1.1.456]   
* [R Suite CLI](http://rsuite.io/RSuite_Download.php) [0.32-245]   
* [Miniconda](https://conda.io/miniconda.html) [4.5.11]   

To be able to build models, you will also need to download and unzip training/validation and test datasets (handwritten MNIST digits).

You can go either with the full dataset ([download MNIST full dataset](https://s3.eu-central-1.amazonaws.com/wlog-share/keras_and_shiny_showcase/mnist_png_full.zip)) which contains 60k examples for training and 10k for testing or a sample ([download MNIST sample](https://s3.eu-central-1.amazonaws.com/wlog-share/keras_and_shiny_showcase/mnist_png.zip)) which has 10k for training and 2.5k for testing.

Of course with the full dataset the model will be significantlny more accurate, but the time for image processing, training and testing will be also much longer. On my 4-core/8-thread Core i7 I was able to build a model on full dataset in about 40 minutes and it had train/val/test accuracy about 98% / 97% / 97%. With just the sample, model building took 8 minutes but the quality was like 94% / 92% / 90%, with exactly the same settings.

## Recreating the case

The first step is to clone or download this repository:

```
>git clone https://github.com/WLOGSolutions/Keras_and_Shiny
```

Then, we will need to install all external R dependencies of our custom packages (which as you can see are three: `DataPreparaton`, `Modeling`, `Application`). You can check the dependencies in `DESCRIPTION` files of each package. To install them with R Suite, you just need to call in the console:

<pre>
>cd ...\Keras_and_Shiny
...\Keras_and_Shiny><b>rsuite proj depsinst</b>
</pre>

You can also use `-v` option when calling `depsinst` (or any other R Suite command) - "v" stands for "verbose" and it will cause showing additional detailed logs of the commands executed underneath - in this case you will be able to see which packages are being installed at the moment. If you don't use `-v` don't worry if the installation takes a few minutes and there's no console output - there are plenty of dependencies to download but at least you don't have to do it manually.

Next, as we will use `Keras` framework which requires Python, we need to build a local Python environment inside our project. This entire environment will be then embedded inside the deployment package, so there is no need to install Python on production. To build the Python (conda) enviroment, which was defined in `DESCRIPTION` file of `DataPreparation` package, we call (optionally with `-v`):

<pre>
...\Keras_and_Shiny><b>rsuite sysreqs install</b>
</pre>

Having the environment set up (both R and Python components) we can build custom packages that contain all functions that will be used to create and use the model (and also the definitions of user interface and server logic for the Shiny app). The command is just:

<pre>
...\Keras_and_Shiny><b>rsuite proj build</b>
</pre>

Everything is almost ready to run the model building script, we only need to point the path to the folder with images that we downloaded and unzipped previously (either `mnist_png` or `mnist_png_full`). To do so, we need to change the `data_path` parameter in `config_templ.txt` which is placed in the main project folder, e.g.:

<pre>
LogLevel: INFO
data_path: <b>C:\Users\Ja\Documents\Projekty\mnist_png_full</b>
train_fraction: 0.83
</pre>

As the master script for model building (`prepare_model.R`) will now know where to look for the data, we can run it using `rscript` command:

<pre>
...\Keras_and_Shiny>cd R
...\Keras_and_Shiny\R><b>rscript prepare_model.R</b>
</pre>

The script will read all images from the given `data_path`, pre-process them, train and test the CNN model and save the model in HDF5 format into `model` folder inside the main project folder.

Model has the following architecture:

![](https://s3.eu-central-1.amazonaws.com/wlog-share/keras_and_shiny_showcase/cnnarchitecture.png)

Having a model, we can now run the Shiny application and see what it can do:

<pre>
...\Keras_and_Shiny\R><b>rscript app.R</b>
</pre>

In a web browser, under [http://localhost:4605](http://localhost:4605), we should be able to see the application running:

![](https://s3.eu-central-1.amazonaws.com/wlog-share/keras_and_shiny_showcase/application.png)

The app allows to read the HDF5 model that we trained and saved a minute ago, load a sample image (it can be created manually in any graphics editor, remembering that it has to be 28 x 28 pixel and grayscale) and use the model to identify the digit by clicking `Identify!` button.

As we tested the solution in dev environment and we see that it is totally amazing, we can prepare a deployment package. First we need to lock the dev environment in case that after some time we will need to recreate it. This will enforce `rsuite proj depsinst` to install exactly the same versions of R packages as used before. The project that we cloned from github is already locked (see the `env.lock` file in `deployment` folder) so it is not neceassary to lock it again, but if we were building the project from scratch, we would call:

<pre>
...\Keras_and_Shiny\R><b>rsuite proj lock</b>
</pre>

The final step is to build a deployment package which as simple as:

<pre>
...\Keras_and_Shiny\R><b>rsuite proj zip --version 1.0</b>
</pre>

When developing the project from scratch and having it under Git or SVN control, we would not need to manually provide `--version`. Also if we want to build the package in a specific directory we can add option for path, e.g. `-p C:\Users\Ja\Desktop\`.

After the deployment package is build, we can see that it contains all scripts, our custom packages as binaries, all R dependencies installed and also the entire conda environment inside. Now you can unzip and run it on any machine that has the same OS (here: Windows x64) and R installed. You do not have to install or configure anything more on production.

## Additional links:

Presentation that shows how this case was built from scratch:

[Link to the presentation](https://s3.eu-central-1.amazonaws.com/wlog-share/keras_and_shiny_showcase/keras_and_shiny_eng_summary.pdf)

Already build deployment package for Windows:

[Link to the deployment package](https://s3.eu-central-1.amazonaws.com/wlog-share/keras_and_shiny_showcase/Keras_and_Shiny_1.0x.zip)


