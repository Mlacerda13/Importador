# 🔑 Painel Importador de Certificados Remoto (v9.2)

O **Importador de Certificados Remoto** é um painel gráfico (WinForms) desenvolvido em **PowerShell** e empacotado como executável (`.exe`) via `PS2EXE`. Ele permite que administradores de rede gerenciem e distribuam certificados digitais (`.cer`, `.crt`, `.pfx`, `.p7b`) em lote para múltiplas máquinas locais ou remotas através do **WinRM**.

---

## 🛠️ Arquitetura e Estrutura do Projeto

* `src/importadorcrt.ps1`: Código-fonte principal com a interface gráfica e a lógica de implantação via `Invoke-Command` e `certutil.exe`.
* `bin/importadorcrt.exe`: Binário gerado para execução direta por administradores sem a necessidade de abrir o console do PowerShell.
* `.gitignore`: Filtro configurado para evitar o rastreamento de arquivos temporários e binários pesados.

---

## ✨ Principais Funcionalidades

1. **Elevação Automática de Privilégios (UAC):**
   * Tenta se autoexecutar como Administrador caso o usuário não tenha permissão elevada.
2. **Definição Flexível de Alvos:**
   * Inserção manual de hostnames ou resolução automática de IP via DNS para *Farms/RDP*.
3. **Gerenciamento de Autenticação:**
   * Suporte a credenciais de domínio/ADM alternativas via `PSCredential`.
4. **Múltiplos Modos de Instalação:**
   * **LocalMachine:** Instala no repositório da máquina (visível a todos os usuários).
   * **CurrentUser:** Instala no repositório do administrador conectado.
   * **LoggedUser_ViaADM:** Instala no repositório do usuário ativo.
   * **ScheduleUser_ViaADM:** Cria uma tarefa agendada via `schtasks.exe` (gatilho `ONLOGON`) para que o certificado seja importado no contexto do colaborador especificado no login.
5. **Suporte a Múltiplos Repositórios:**
   * Importação para `Root` (Autoridades Raiz), `My` (Pessoal) e `CA` (Intermediárias).
6. **Suporte a Certificados PFX com Senha:**
   * Descompactação e instalação remota com proteção de senha via `certutil.exe`.

---

## 🚀 Como Utilizar

### Pré-requisitos
* **Sistema Operacional:** Windows 10/11 ou Windows Server
* **PowerShell:** 5.1 ou superior
* **Rede:** Gerenciamento remoto (WinRM) habilitado nas máquinas destino (`Enable-PSRemoting`).

### Executando via Código Fonte (`.ps1`)
1. Abra o PowerShell como Administrador.
2. Execute o script:
   ```powershell
   .\src\importadorcrt.ps1
