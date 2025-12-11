# Micromamba DevContainer Feature Notes

## Integration with SunshineCloud Universal Desktop

This micromamba feature is specifically configured for use with the SunshineCloud Universal Desktop environment, providing conda package management for AI/ML and data science workflows.

## Key Features

### Fast Package Management
- Micromamba provides faster package resolution and installation compared to standard conda
- Optimized for container environments
- Minimal memory footprint

### Pre-configured Channels
The feature is pre-configured with commonly used channels:
- conda-forge (primary channel)
- defaults (fallback)

### AI/ML Package Support  
Common packages available through this feature:
- Python scientific stack (numpy, pandas, scipy)
- Machine learning libraries (scikit-learn, tensorflow, pytorch)
- Jupyter notebook ecosystem
- Data visualization tools (matplotlib, seaborn, plotly)

## Usage in AI Desktop Environments

This feature is automatically included in all AI desktop environments:
- ComfyUI Desktop
- Fooocus Desktop  
- WebUI Desktop
- WebUI Forge Desktop
- Text Generation Desktop

## Environment Management

### Creating Environments
Environments can be created using specification files or direct package lists.

```dockerfile
FROM mcr.microsoft.com/devcontainers/base:debian
COPY specfile.yml /tmp/specfile.yml
```

...copies the following `specfile.yml` to the container.

```yml
name: testenv
channels:
### Example AI/ML Environment
```yaml
name: ai-env
channels:
  - conda-forge
  - pytorch
dependencies:
  - python=3.11
  - pytorch
  - torchvision
  - torchaudio
  - pytorch-cuda=12.1
  - transformers
  - diffusers
  - accelerate
  - jupyter
  - matplotlib
```

## Performance Considerations

### Container Optimization
- Micromamba is pre-installed during image build to reduce startup time
- Common packages are cached in the base image
- Environment activation is automatic

### GPU Support
- CUDA-enabled packages are available through conda channels
- PyTorch GPU builds are optimized for the container environment
- Environment variables are pre-configured for GPU acceleration

## Troubleshooting

### Common Issues
- Ensure version numbers are fully specified (X.Y.Z format)
- Check channel availability for specific packages
- Verify GPU drivers are available for CUDA packages

### Integration Notes
This feature works seamlessly with other SunshineCloud Universal Desktop features including GPU support, Ollama integration, and desktop environment components.
