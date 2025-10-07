class QuickOrgCreator < Formula
  desc "Script to ease the process of creating Salesforce scratch orgs"
  homepage "https://github.com/mvogelgesang/homebrew-quick-org-creator"
  # LOCAL url "https://github.com/mvogelgesang/quick-org-creator/archive/refs/tags/v0.4.2.tar.gz"
  # LOCAL sha256 "6c477aeee4666c462f5ef581ac729fc2811b33806385334c92fb156b74a38f34"
  url "https://github.com/mvogelgesang/quick-org-creator/archive/refs/tags/v0.4.2.tar.gz"
    version "0.4.2"
  sha256 "6c477aeee4666c462f5ef581ac729fc2811b33806385334c92fb156b74a38f34"
  license "MIT"

  depends_on "gh"
  depends_on "jq"

  def install
    libexec.install Dir["src/*"]
    libexec.install Dir["fileTemplates/"]
    libexec.install Dir["..scratchDefs/"]
    libexec.install "VERSION"
    bin.install_symlink libexec/"run.sh" => "oc"
  end

  test do
    system "#{bin}/oc", "namespace"
  end
end
