import torch
import torchvision
import monai
import lightning
import numpy
import platform

def check_setup():
    # Configuration requirements
    reqs = {
        "torch": "2.2.2",
        "torchvision": "0.17.2",
        "monai": "1.3.2",
        "lightning": "2.6.0",
        "numpy": "2.3.5"
    }

    print(f"{'='*50}")
    print(f"🚀 SYSTEM & ENVIRONMENT DIAGNOSTIC")
    print(f"{'='*50}")
    
    # 1. OS and Python Info
    print(f"OS: {platform.system()} {platform.release()}")
    print(f"Python: {platform.python_version()}")
    print("-" * 50)

    # 2. Dependency Checks
    packages = [
        ("PyTorch", torch.__version__, reqs["torch"]),
        ("Torchvision", torchvision.__version__, reqs["torchvision"]),
        ("MONAI", monai.__version__, reqs["monai"]),
        ("Lightning", lightning.__version__, reqs["lightning"]),
        ("NumPy", numpy.__version__, reqs["numpy"]),
    ]

    print(f"{'LIBRARY':<15} | {'INSTALLED':<12} | {'REQUIRED':<10} | {'STATUS'}")
    print("-" * 50)

    for name, version, req in packages:
        # Simple version comparison (stripping suffixes like +cu121)
        is_ok = version.split('+')[0] >= req
        status = "✅ OK" if is_ok else "⚠️  UPDATE"
        print(f"{name:<15} | {version:<12} | >={req:<10} | {status}")

    print("-" * 50)

    # 3. GPU / CUDA Check
    print(f"CUDA AVAILABLE: {'✅ YES' if torch.cuda.is_available() else '❌ NO'}")
    
    if torch.cuda.is_available():
        current_device = torch.cuda.current_device()
        print(f"GPU Device:     {torch.cuda.get_device_name(current_device)}")
        print(f"CUDA Version:   {torch.version.cuda}")
        print(f"CUDNN Version:  {torch.backends.cudnn.version()}")
        
        # Memory Check
        mem_alloc = torch.cuda.memory_allocated(current_device) / 1024**3
        mem_cached = torch.cuda.memory_reserved(current_device) / 1024**3
        print(f"Memory Usage:   Allocated: {mem_alloc:.2f}GB | Reserved: {mem_cached:.2f}GB")
        
        # MONAI Specific GPU Test
        try:
            from monai.utils import get_torch_device_name
            print(f"MONAI Device:   {get_torch_device_name(current_device)}")
        except:
            pass
    else:
        print("🔴 WARNING: Torch cannot see your GPU. Check drivers and 'nvcc --version'.")

    print(f"{'='*50}")

if __name__ == "__main__":
    check_setup()
