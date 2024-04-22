class QuickOrgCreator < Formula
  desc "Script to ease the process of creating Salesforce scratch orgs"
  homepage "https://github.com/mvogelgesang/homebrew-quick-org-creator"
  # LOCAL url "file://localhost/Users/mvogelgesang/Develop/quick-org-creator/tmp9.tar.gz"
  # LOCAL sha256 "becfae0bc2b8b9876928948a5b730a145459984ba399ccda1c3a32b33f3a57f4"
  # LOCAL version "0.2.2"
  url "https://github.com/mvogelgesang/homebrew-quick-org-creator/archive/refs/tags/v0.3.1.tar.gz"
  sha256 "9c4aca9f857c36143e6dad8d8b1834b2cf7f9c4db3e1acb352adfd4f8ba97967"
  license "MIT"

  depends_on "gh"
  depends_on "jq"

  def install
    libexec.install Dir["src/*"]
    libexec.install Dir["fileTemplates/"]
    libexec.install Dir["..scratchDefs/"]
    bin.install_symlink libexec/"run.sh" => "oc"
  end

  test do
    system "#{bin}/oc", "namespace"
  end
end
