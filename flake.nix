{
  description = "DepthAIv3 flake";

  inputs = {
    # Nixpkgs repository with packaged DepthAIv3 and it's dependencies
     nixpkgs.url = "github:phodina/nixpkgs?ref=depthaiv3_alpha15";
  };

  # Give hint for binary cache to download prebuilt packages
  nixConfig = {
    extra-substituters = [
      "https://phodina-luxonis-depthai.cachix.org"
    ];
    extra-trusted-public-keys = [
      "phodina-luxonis-depthai.cachix.org-1:5GSc05BoSuEyBf0ifMQzu4bUUiE8QUJRiGFRxxD+/Yc="
    ];
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        
        # Define Python packages to include in the environment
        pythonPackages = ps: with ps; [
          # Basic tools
          pip
          setuptools
          wheel
          ipython
          
          # Development tools
          pytest
          black
          flake8
          mypy
          
          # Add any other packages you need
          scipy
          matplotlib

          #NOTE: OpenCV is already added as it has dependency on GTK to show windows
        ];
        
        # Create a Python with selected packages
        pythonEnv = pkgs.python3.withPackages pythonPackages;
        
        # Ensure the docker image will display GUI Windows
        guiPackages = with pkgs; [
          xorg.libX11
          xorg.libXcursor
          xorg.libXrandr
          xorg.libXi
          xorg.libXfixes
          xorg.libXcomposite
          xorg.libXdamage
          xorg.libXext
          xorg.libXrender
          xorg.libXtst
          xorg.libXinerama
          xorg.libxcb
          xorg.libXScrnSaver
          glfw
          libGL
          vulkan-loader
          mesa
          glib
          gtk3
          pango
          atk
          gdk-pixbuf
          cairo
        ];
      in {
        devShells.default = pkgs.mkShell {
          buildInputs = [
            pythonEnv
            pkgs.depthai-core
          ];
 
          shellHook = ''
            # Get the current working directory
            CURRENT_DIR=$(pwd)

            # Create and activate Python virtual environment if it doesn't exist
            if [ ! -d ".venv" ]; then
              echo "Creating virtual environment..."
              ${pkgs.python3}/bin/python -m venv .venv
            fi
            
            # Add the virtual environment to PYTHONPATH
            export PYTHONPATH=$CURRENT_DIR/.venv:$PYTHONPATH
            
            # Add local bin directory to PATH
            export PATH=$CURRENT_DIR/.venv/bin:$PATH
            
            # Display Python information
            echo -e "\e[31mPython development environment activated\e[0m"
            echo -e "\e[31mPython version: $(python --version)\e[0m"
            echo -e "\e[31mDepthAI version: $(python -c "import depthai as dai; print(dai.__version__);")\e[0m"
            echo -e "\e[31mPython path: $(which python)\e[0m"
            
            # You can add project-specific configurations here
            # export PROJECT_HOME=$CURRENT_DIR
            
            # Set custom prompt to indicate we're in a dev shell
            export PS1="(py-dev) \[\033[1;32m\]\w\[\033[0m\] > "
          '';
        };

        packages.docker-image = pkgs.dockerTools.buildLayeredImage {
          name = "depthai-image";
          tag = "latest";

          contents = [
            pkgs.bashInteractive
            pkgs.coreutils

            pythonEnv
            pkgs.depthai-core

            pkgs.gcc-unwrapped.lib
            pkgs.zlib

            pkgs.iproute2
            pkgs.nettools

            guiPackages
          ];

          config = {
            Env = [
              "LD_LIBRARY_PATH=${pkgs.lib.makeLibraryPath [
                pkgs.gcc-unwrapped.lib
                pkgs.zlib
                pkgs.wayland-protocols
                pkgs.xorg.libX11
                pkgs.xorg.libXcursor
                pkgs.xorg.libXrandr
                pkgs.xorg.libXi
                pkgs.vulkan-loader
                pkgs.libGL
                pkgs.glib.out
              ]}"
              "DISPLAY=:0"
              "QT_X11_NO_MITSHM=1"
              "NO_AT_BRIDGE=1"
              "PYTHONPATH=${pythonEnv}/${pythonEnv.sitePackages}:${pkgs.depthai-core}/${pythonEnv.sitePackages}"
            ];
            WorkingDir = "/app";
            Cmd = ["${pkgs.bashInteractive}/bin/bash"];

            NetworkDisabled = false;

            Volumes = {
              "/dev/bus/usb" = {};
              "/tmp/.X11-unix" = {};
            };

            CapAdd = ["SYS_PTRACE"];

           extraCommands = ''
            mkdir -p mnt
            chmod 777 mnt
            # Create the entrypoint script to handle user/group setup
            mkdir -p usr/bin
            cat > usr/bin/entrypoint.sh << 'EOF'
            #!/bin/bash
            set -e
              USER_ID=${LOCAL_USER_ID:-1000}
              GROUP_ID=${LOCAL_GROUP_ID:-1000}
EOF
            chmod +x usr/bin/entrypoint.sh
'';
     };
};
      }
    );
}
