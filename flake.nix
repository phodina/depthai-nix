{
  description = "DepthAIv3 flake";

  inputs = {
    # Default nixpkgs repository
    # nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    # Nixpkgs repository with packaged DepthAIv3 and it's dependencies
    nixpkgs.url = "github:phodina/nixpkgs?ref=depthaiv3_upstream";
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
            echo "Python development environment activated"
            echo "Python version: $(python --version)"
            echo "Python path: $(which python)"
            
            # You can add project-specific configurations here
            # export PROJECT_HOME=$CURRENT_DIR
            
            # Set custom prompt to indicate we're in a dev shell
            export PS1="(py-dev) \[\033[1;32m\]\w\[\033[0m\] > "
          '';
        };
      }
    );
}
