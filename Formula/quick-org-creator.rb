class QuickOrgCreator < Formula
  desc "Script to ease the process of creating Salesforce scratch orgs"
  homepage "https://github.com/mvogelgesang/homebrew-quick-org-creator"
  # LOCAL url "https://github.com/mvogelgesang/quick-org-creator/archive/refs/tags/v0.4.1.tar.gz"
  # LOCAL sha256 "7860f38b8ca9171b7e71cbfc49ab0353979729a1f134fea3b953f4842764c951"
  version File.read("VERSION").strip
  url "https://github.com/mvogelgesang/quick-org-creator/archive/refs/tags/v0.4.1.tar.gz"
  sha256 "7860f38b8ca9171b7e71cbfc49ab0353979729a1f134fea3b953f4842764c951"
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
