# Importador
Importar Certificados Windows por FARM, IP ou Hostname

# 🔒 Importador de Certificados (CRT) - Builder

Script de automação em PowerShell responsável por compilar o utilitário de importação/reinicialização de certificados digitais em um executável autônomo (`.exe`) sem interface de console.

## ⚙️ Como Funciona

O projeto utiliza o módulo **PS2EXE** para converter o script interno `Reiniciador.ps1` em um executável `.exe` pronto para distribuição em ambientes Windows.

## 🚀 Como Utilizar

### Pré-requisitos
- Windows 10/11 ou Windows Server
- PowerShell 5.1 ou superior
- Permissão para execução de scripts no PowerShell

### Passos para Gerar o Executável

1. **Clone o repositório:**
   ```powershell
   git clone [https://github.com/seu-usuario/importador-crt.git](https://github.com/seu-usuario/importador-crt.git)
   cd importador-crt
