# Installation Troubleshooting Guide

Comprehensive solutions for common TensorFlow for R installation issues.

## Common Issues by Platform

### Issue: "ModuleNotFoundError: No module named 'tensorflow'"

**Symptoms**: After running `library(tensorflow)`, calling `tf$constant()` fails with module not found.

**Causes**:
- TensorFlow not installed in the R environment
- Wrong Python environment selected
- Corrupted installation

**Solutions**:

```r
# Solution 1: Force reinstall
library(tensorflow)
install_tensorflow(force = TRUE)

# Solution 2: Specify method explicitly
install_tensorflow(method = "virtualenv", envname = "r-tensorflow-new")

# Solution 3: Check Python environment
library(reticulate)
py_config()  # Verify which Python is being used

# Solution 4: Manual environment specification
Sys.setenv(RETICULATE_PYTHON = "~/.virtualenvs/r-tensorflow/bin/python")
library(tensorflow)
```

---

### Issue: "Environment exists but is not a virtualenv"

**Symptoms**: `install_tensorflow()` fails with error about existing environment.

**Cause**: Corrupted or mismatched environment.

**Solution**:

```r
# Remove corrupted environment
reticulate::virtualenv_remove("r-tensorflow")

# Create fresh environment
install_tensorflow(envname = "r-tensorflow-fresh")
```

---

### Issue: GPU Not Detected

**Platform**: Linux, Windows (WSL), Mac

**Check GPU availability**:
```r
library(tensorflow)
tf$config$list_physical_devices("GPU")
# Should return list with GPU devices, not empty list
```

**Solutions by Platform**:

#### Linux

```r
# TensorFlow v2.16.0+ has automatic CUDA/cuDNN installation
install_tensorflow()  # Auto-detects and installs GPU support

# If that fails, install CUDA manually
# Check CUDA version required by TensorFlow version
# https://www.tensorflow.org/install/source#gpu

# Manual CUDA 11.8 example (Ubuntu)
# sudo apt install nvidia-cuda-toolkit
# sudo apt install libcudnn8 libcudnn8-dev

# Verify CUDA
system("nvidia-smi")

# Set CUDA paths if needed
Sys.setenv(
  CUDA_HOME = "/usr/local/cuda",
  LD_LIBRARY_PATH = paste0(
    "/usr/local/cuda/lib64:",
    Sys.getenv("LD_LIBRARY_PATH")
  )
)
```

#### Windows (WSL)

```r
# Use latest tensorflow (v2.20.0+) with improved WSL support
install_tensorflow(version = "latest")

# Verify GPU in WSL
system("nvidia-smi")  # Should show GPU

# If fails, update WSL
# In PowerShell: wsl --update
```

#### macOS (M1/M2)

```r
# Mac uses Metal backend, not CUDA
# TensorFlow 2.12+ has ARM64 support

install_tensorflow(method = "virtualenv")

# For Apple Silicon optimization
# Consider using keras3 with JAX backend instead:
# Sys.setenv(KERAS_BACKEND = "jax")
```

**Note**: TensorFlow GPU support on macOS (Intel) is deprecated. Use CPU version or consider alternative frameworks (torch has better Mac GPU support via MPS).

---

### Issue: Version Incompatibility

**Symptoms**: "Cannot install TF versions less than X.X"

**Cause**: Package manager constraints or Python version incompatibility.

**Solutions**:

```r
# Check Python version
reticulate::py_config()

# Install specific TensorFlow version
install_tensorflow(version = "2.14")

# Or use version range
install_tensorflow(version = "2.14.0")

# Specify compatible Python version
install_tensorflow(
  version = "2.14",
  python_version = "3.10"
)
```

---

### Issue: NumPy Compatibility Errors

**Symptoms**: Errors mentioning NumPy version conflicts or array API.

**Cause**: NumPy 2.0 breaking changes.

**Solution**:

```r
# Use latest tensorflow (v2.20.0+) with NumPy 2.0 support
install_tensorflow(version = "latest")

# Or pin NumPy version
install_tensorflow(extra_packages = c("numpy==1.26.4"))
```

---

### Issue: Conda vs Pip Conflicts

**Symptoms**: Installation succeeds but TensorFlow not found, or package conflicts.

**Cause**: Mixed conda/pip environments.

**Solution**:

```r
# Choose one method consistently

# Option 1: Pure virtualenv (recommended for most users)
install_tensorflow(method = "virtualenv")

# Option 2: Pure conda (recommended for Windows)
install_tensorflow(method = "conda")

# Clean up mixed environments
reticulate::virtualenv_remove("r-tensorflow")
reticulate::conda_remove("r-tensorflow")

# Start fresh with chosen method
install_tensorflow(method = "virtualenv", envname = "r-tf-clean")
```

---

### Issue: SSL Certificate Errors

**Symptoms**: Download fails with SSL certificate verification errors.

**Cause**: Corporate proxy or outdated CA certificates.

**Solutions**:

```r
# Option 1: Update CA certificates (Linux)
# sudo apt-get install ca-certificates

# Option 2: Use conda (handles SSL better)
install_tensorflow(method = "conda")

# Option 3: Configure pip to use proxy (if behind corporate firewall)
# Edit ~/.pip/pip.conf or %APPDATA%\pip\pip.ini
# [global]
# trusted-host = pypi.org files.pythonhosted.org
```

---

### Issue: Memory/Disk Space Errors

**Symptoms**: Installation fails with "No space left on device" or memory errors.

**Cause**: TensorFlow is large (~500MB), plus dependencies.

**Solutions**:

```r
# Install CPU-only version (smaller)
install_tensorflow(version = "cpu")

# Clean pip cache
system("pip cache purge")

# Check disk space
system("df -h ~")  # Linux/Mac
system("dir")  # Windows
```

---

### Issue: Old TensorFlow Already Loaded

**Symptoms**: "TensorFlow is already loaded" error during installation.

**Cause**: Cannot modify loaded Python modules.

**Solution**:

```r
# Restart R session before installing
# In RStudio: Session > Restart R
# Or
.rs.restartR()

# Then install
install_tensorflow()
```

---

## Platform-Specific Issues

### Ubuntu: Obsolete NVIDIA Repository Key

**Symptoms**: CUDA installation fails with GPG key errors.

**Solution**:

```bash
# Remove obsolete key
sudo apt-key del 7fa2af80

# Add new key
wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2204/x86_64/cuda-keyring_1.0-1_all.deb
sudo dpkg -i cuda-keyring_1.0-1_all.deb

# Update and install
sudo apt update
sudo apt install cuda
```

---

### Windows: DLL Load Failed

**Symptoms**: "DLL load failed" or missing MSVCP140.dll errors.

**Cause**: Missing Visual C++ Redistributables.

**Solution**:

1. Download and install Visual C++ Redistributables:
   https://aka.ms/vs/17/release/vc_redist.x64.exe

2. Restart computer

3. Reinstall TensorFlow:
```r
install_tensorflow(method = "conda")  # Recommended for Windows
```

---

### macOS: Library Not Loaded (libomp)

**Symptoms**: "Library not loaded: libomp.dylib" errors.

**Cause**: Missing OpenMP library.

**Solution**:

```bash
# Install via Homebrew
brew install libomp

# Or link existing
ln -s /usr/local/opt/libomp/lib/libomp.dylib /usr/local/lib/libomp.dylib
```

---

## Docker and Container Issues

### Issue: GPU Not Available in Docker

**Solution**:

```dockerfile
# Use NVIDIA Container Toolkit
# docker run --gpus all ...

# Or docker-compose.yml
services:
  r-tensorflow:
    runtime: nvidia
    environment:
      - NVIDIA_VISIBLE_DEVICES=all
```

**Base Image**:
```dockerfile
FROM rocker/r-ver:4.3.0

RUN apt-get update && apt-get install -y \
    python3-pip \
    python3-venv

RUN R -e "install.packages('tensorflow')"
RUN R -e "tensorflow::install_tensorflow()"
```

---

## Cloud Platform Issues

### Google Colab

**Issue**: Cannot detect GPU in Colab notebook running R.

**Workaround**:

```r
# Check if GPU available
system("nvidia-smi")

# Set visible devices
Sys.setenv(CUDA_VISIBLE_DEVICES = "0")

# Use CPU version if GPU detection fails
install_tensorflow(version = "cpu")
```

---

### AWS/GCP/Azure

**Issue**: GPU not detected on cloud instances.

**Checklist**:
1. Verify instance type has GPU (e.g., p2.xlarge, n1-standard-4)
2. Check NVIDIA drivers installed: `nvidia-smi`
3. Verify CUDA installation
4. Check TensorFlow version compatibility

---

## Version-Specific Issues

### TensorFlow 2.16+ (keras3 Integration)

**Changes**:
- keras3 is now the recommended package (not old keras)
- Automatic CUDA/cuDNN installation on Linux

**Migration**:

```r
# Remove old keras
remove.packages("keras")

# Install keras3
install.packages("keras3")

# Install TensorFlow 2.16+
install_tensorflow(version = "2.16.0")
```

---

### TensorFlow 2.7.0 (Breaking Changes)

**shape() behavior changed**:

```r
# Old code (< 2.7.0)
shape <- shape(tensor)  # Returns R list
dim1 <- shape[[1]]

# New code (>= 2.7.0)
shape <- shape(tensor)  # Returns tf.TensorShape object
dim1 <- as.integer(shape)[[1]]
# Or
dim1 <- shape[[1]]  # Still works but returns TensorShape object
```

**Migration**:
Use `as.list()`, `as.integer()`, or `[[` for conversion to R objects.

---

## Diagnostic Commands

Run these to diagnose issues:

```r
# Check R environment
sessionInfo()

# Check Python configuration
library(reticulate)
py_config()
py_discover_config()

# List available environments
virtualenv_list()
conda_list()

# Check TensorFlow installation
library(tensorflow)
tf_version()
tf_config()

# Test basic operation
tf$constant("Hello TensorFlow!")

# Check GPU
tf$config$list_physical_devices("GPU")

# Check CUDA (Linux)
system("nvidia-smi")
system("nvcc --version")
```

---

## Clean Slate Approach

When all else fails, start completely fresh:

```r
# 1. Remove all environments
reticulate::virtualenv_remove("r-tensorflow")
reticulate::conda_remove("r-tensorflow")

# 2. Restart R session
.rs.restartR()

# 3. Reinstall reticulate
remove.packages("reticulate")
install.packages("reticulate")

# 4. Reinstall tensorflow
remove.packages("tensorflow")
install.packages("tensorflow")

# 5. Install Python
library(reticulate)
install_python()

# 6. Install TensorFlow
library(tensorflow)
install_tensorflow(envname = "r-tf-fresh")

# 7. Verify
tf$constant("Success!")
```

---

## Getting Help

If issues persist:

1. **Check GitHub Issues**: https://github.com/rstudio/tensorflow/issues

2. **Provide diagnostic info**:
```r
library(tensorflow)
tf_config()
reticulate::py_config()
sessionInfo()
```

3. **RStudio Community**: https://community.rstudio.com/c/ml

4. **Stack Overflow**: Tag with `[r]` and `[tensorflow]`

---

## Prevention Best Practices

### For New Projects

```r
# 1. Use project-specific environments
install_tensorflow(envname = "project-name-tf")

# 2. Document versions
# Add to README.md:
# TensorFlow: 2.14.0
# Python: 3.10
# R: 4.3.0

# 3. Pin versions in renv
renv::init()
renv::snapshot()

# 4. Test immediately
tf$constant("Test")
```

### For Reproducibility

```r
# Save environment info
writeLines(capture.output(sessionInfo()), "session_info.txt")
writeLines(capture.output(reticulate::py_config()), "python_config.txt")

# Use Docker for maximum reproducibility
# Create Dockerfile with specific versions
```

---

## Quick Reference: Common Fixes

| Error | Quick Fix |
|-------|-----------|
| Module not found | `install_tensorflow(force = TRUE)` |
| Environment corrupted | `virtualenv_remove()` + fresh install |
| GPU not detected | Update drivers, use v2.16.0+ |
| Version conflict | Specify `version` and `python_version` |
| DLL load failed (Windows) | Install VC++ Redistributables |
| SSL errors | Use conda method |
| NumPy errors | Use latest tensorflow (v2.20.0+) |
| Out of memory | Install CPU-only version |
| Already loaded | Restart R session |

---

## Summary

Most installation issues stem from:
1. **Environment conflicts** (mixed conda/pip)
2. **GPU driver mismatches**
3. **Python version incompatibility**
4. **Corrupted installations**

**Golden Rule**: When in doubt, **start fresh** with a new environment name and explicit version specifications.

**Recommended Setup**:
```r
# Safe, reproducible installation
library(tensorflow)
install_tensorflow(
  method = "virtualenv",
  version = "2.16.0",
  envname = "my-project-tf",
  python_version = "3.10"
)

# Verify
tf$constant("Success!")
tf$config$list_physical_devices("GPU")
```
