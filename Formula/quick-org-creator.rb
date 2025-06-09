class QuickOrgCreator < Formula
  desc "Script to ease the process of creating Salesforce scratch orgs"
  homepage "https://github.com/mvogelgesang/homebrew-quick-org-creator"
  # LOCAL url "file://localhost/Users/mvogelgesang/Develop/homebrew-quick-org-creator/tmp-quick-org-creator.tar.gz"
  # LOCAL sha256 "0b821e301329f35bfcbec8fc25d88b26ec9fde165c046cbc5dfe619d921d7599"
  version File.read("VERSION").strip
  url "https://github.com/mvogelgesang/homebrew-quick-org-creator/archive/refs/tags/v0.3.5.tar.gz"
  sha256 "4149be8865f9e644a33d2719ed1510aad56657316f8e22c2547219844384cb5d"
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
