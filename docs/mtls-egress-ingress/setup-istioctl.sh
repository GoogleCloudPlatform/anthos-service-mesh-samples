ASM_VERSION="1.6.11-asm.1"

uname_out="$(uname -s)"
case "${uname_out}" in
    Linux*)     OS=linux-amd64;;
    Darwin*)    OS=osx;;
    *)          exit;
esac

SUFFIX=${ASM_VERSION}-${OS}

curl -LO https://storage.googleapis.com/gke-release/asm/istio-${SUFFIX}.tar.gz
tar xzf istio-${SUFFIX}.tar.gz

cd istio-${ASM_VERSION}
export PATH=$PWD/bin:$PATH
