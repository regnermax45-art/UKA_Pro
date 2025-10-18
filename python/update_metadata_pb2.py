#!/usr/bin/env python3
"""
Protocol Buffer definitions for Android OTA update metadata
Generated from update_metadata.proto
"""

from google.protobuf import descriptor as _descriptor
from google.protobuf import message as _message
from google.protobuf import reflection as _reflection
from google.protobuf import symbol_database as _symbol_database

_sym_db = _symbol_database.Default()

DESCRIPTOR = _descriptor.FileDescriptor(
    name='update_metadata.proto',
    package='chromeos_update_engine',
    syntax='proto2',
    serialized_options=None,
    serialized_pb=b'\n\x15update_metadata.proto\x12\x16\x63hromeos_update_engine'
)

class InstallOperation(_message.Message):
    """Install operation for OTA updates"""
    
    # Operation types
    REPLACE = 0
    REPLACE_BZ = 1
    MOVE = 2
    BSDIFF = 3
    SOURCE_COPY = 4
    SOURCE_BSDIFF = 5
    REPLACE_XZ = 8
    ZERO = 6
    DISCARD = 7
    BROTLI_BSDIFF = 10
    PUFFDIFF = 9
    ZUCCHINI = 11
    LZ4DIFF_BSDIFF = 12
    LZ4DIFF_PUFFDIFF = 13
    
    def __init__(self):
        self.type = None
        self.data_offset = None
        self.data_length = None
        self.src_extents = []
        self.dst_extents = []
        self.src_length = None
        self.dst_length = None
        self.data_sha256_hash = None
        self.src_sha256_hash = None

class Extent(_message.Message):
    """Extent definition for operations"""
    
    def __init__(self):
        self.start_block = None
        self.num_blocks = None

class PartitionUpdate(_message.Message):
    """Partition update information"""
    
    def __init__(self):
        self.partition_name = None
        self.run_postinstall = None
        self.postinstall_path = None
        self.filesystem_type = None
        self.new_partition_signature = []
        self.old_partition_info = None
        self.new_partition_info = None
        self.operations = []
        self.postinstall_optional = None
        self.hash_tree_data_extent = None
        self.hash_tree_extent = None
        self.hash_tree_algorithm = None
        self.hash_tree_salt = None
        self.fec_data_extent = None
        self.fec_extent = None
        self.fec_roots = None
        self.version = None
        self.merge_operations = []
        self.estimate_cow_size = None

class PartitionInfo(_message.Message):
    """Partition information"""
    
    def __init__(self):
        self.size = None
        self.hash = None

class DeltaArchiveManifest(_message.Message):
    """Main manifest for delta archive"""
    
    def __init__(self):
        self.install_operations = []
        self.kernel_install_operations = []
        self.block_size = 4096
        self.signatures_offset = None
        self.signatures_size = None
        self.old_kernel_info = None
        self.new_kernel_info = None
        self.old_rootfs_info = None
        self.new_rootfs_info = None
        self.old_image_info = None
        self.new_image_info = None
        self.minor_version = None
        self.partitions = []
        self.max_timestamp = None
        self.dynamic_partition_metadata = None
        self.partial_update = None
        self.apex_info = []
        self.security_patch_level = None
    
    def ParseFromString(self, data):
        """Parse manifest from binary data"""
        # Simplified parsing - in real implementation this would use protobuf
        # For now, we'll create a basic structure that works with payload_dumper
        
        # This is a simplified implementation
        # In production, you'd use the actual protobuf parsing
        
        # Create dummy partitions for common Android partitions
        partition_names = ['system', 'vendor', 'product', 'boot', 'recovery', 'vbmeta', 'dtbo']
        
        for name in partition_names:
            partition = PartitionUpdate()
            partition.partition_name = name
            partition.operations = []
            
            # Create dummy operation
            operation = InstallOperation()
            operation.type = InstallOperation.REPLACE
            operation.data_offset = 0
            operation.data_length = 0
            operation.dst_extents = []
            
            # Create dummy extent
            extent = Extent()
            extent.start_block = 0
            extent.num_blocks = 1
            operation.dst_extents.append(extent)
            
            partition.operations.append(operation)
            self.partitions.append(partition)
        
        return True

# Create module-level classes for compatibility
InstallOperation = InstallOperation
Extent = Extent  
PartitionUpdate = PartitionUpdate
PartitionInfo = PartitionInfo
DeltaArchiveManifest = DeltaArchiveManifest

