# mount_disks.ps1

# Get the list of all disks
$disks = Get-Disk | Where-Object { $_.PartitionCount -eq 0 }

# Assign drive letters
$driveLetters = @("X", "Y")

for ($i = 0; $i -lt $disks.Count; $i++) {
    if ($i -lt $driveLetters.Count) {
        $disk = $disks[$i]
        # Initialize the disk
        Initialize-Disk -Number $disk.Number -PartitionStyle MBR -PassThru | 
        New-Partition -DriveLetter $driveLetters[$i] -UseMaximumSize | 
        Format-Volume -FileSystem NTFS -Confirm:$false
    }
}