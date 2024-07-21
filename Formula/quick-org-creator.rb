class QuickOrgCreator < Formula
  desc "Script to ease the process of creating Salesforce scratch orgs"
  homepage "https://github.com/mvogelgesang/homebrew-quick-org-creator"
  # LOCAL url "file://localhost/Users/mvogelgesang/Develop/homebrew-quick-org-creator/tmp-quick-org-creator.tar.gz"
  # LOCAL sha256 "0b821e301329f35bfcbec8fc25d88b26ec9fde165c046cbc5dfe619d921d7599"
  version File.read("VERSION").strip
  url "https://github.com/mvogelgesang/homebrew-quick-org-creator/archive/refs/tags/v0.3.4.tar.gz"
  sha256 "1f0a0665d2fcfe601d3ec2b26071ae72b7d6a6cb202f2c8ce76ae3ece8f112b4"
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
