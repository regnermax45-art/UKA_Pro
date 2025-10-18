#!/usr/bin/env python3
"""
Payload Dumper for Android OTA Updates
Enhanced for Pixel 7 Pro GSI porting
Based on payload_dumper by vm03
"""

import argparse
import bz2
import hashlib
import lzma
import os
import struct
import sys
from concurrent.futures import ThreadPoolExecutor

try:
    import update_metadata_pb2
except ImportError:
    print("Error: update_metadata_pb2 module not found")
    print("Please install protobuf: pip3 install protobuf")
    sys.exit(1)

class PayloadDumper:
    def __init__(self, payload_file, output_dir=".", partitions=None):
        self.payload_file = payload_file
        self.output_dir = output_dir
        self.partitions = partitions or []
        self.block_size = 4096
        
    def _decompress_data(self, data, compression_type):
        """Decompress data based on compression type"""
        if compression_type == update_metadata_pb2.InstallOperation.REPLACE:
            return data
        elif compression_type == update_metadata_pb2.InstallOperation.REPLACE_BZ:
            return bz2.decompress(data)
        elif compression_type == update_metadata_pb2.InstallOperation.REPLACE_XZ:
            return lzma.decompress(data)
        else:
            return data
    
    def _extract_partition(self, partition, payload_file):
        """Extract a single partition"""
        partition_name = partition.partition_name
        
        # Skip if specific partitions requested and this isn't one
        if self.partitions and partition_name not in self.partitions:
            return
            
        print(f"📦 Extracting {partition_name}...")
        
        output_file = os.path.join(self.output_dir, f"{partition_name}.img")
        
        with open(output_file, 'wb') as out_file:
            for operation in partition.operations:
                payload_file.seek(operation.data_offset)
                data = payload_file.read(operation.data_length)
                
                # Decompress if needed
                data = self._decompress_data(data, operation.type)
                
                # Write to output
                if hasattr(operation, 'dst_extents'):
                    for extent in operation.dst_extents:
                        out_file.seek(extent.start_block * self.block_size)
                        out_file.write(data[:extent.num_blocks * self.block_size])
                        data = data[extent.num_blocks * self.block_size:]
                else:
                    out_file.write(data)
        
        print(f"✅ {partition_name}.img extracted ({os.path.getsize(output_file)} bytes)")
    
    def extract(self):
        """Extract payload.bin"""
        if not os.path.exists(self.payload_file):
            print(f"❌ Error: {self.payload_file} not found")
            return False
            
        print(f"🔧 Processing {self.payload_file}...")
        
        # Create output directory
        os.makedirs(self.output_dir, exist_ok=True)
        
        with open(self.payload_file, 'rb') as payload:
            # Read payload header
            magic = payload.read(4)
            if magic != b'CrAU':
                print("❌ Error: Invalid payload file (missing CrAU magic)")
                return False
                
            # Read version
            version = struct.unpack('>Q', payload.read(8))[0]
            print(f"📋 Payload version: {version}")
            
            # Read manifest size
            manifest_size = struct.unpack('>Q', payload.read(8))[0]
            
            # Read metadata signature size
            metadata_signature_size = struct.unpack('>I', payload.read(4))[0]
            
            # Read manifest
            manifest_data = payload.read(manifest_size)
            
            # Skip metadata signature
            payload.seek(metadata_signature_size, 1)
            
            # Parse manifest
            manifest = update_metadata_pb2.DeltaArchiveManifest()
            manifest.ParseFromString(manifest_data)
            
            print(f"📊 Found {len(manifest.partitions)} partitions")
            
            # Extract partitions
            pixel_partitions = ['system', 'vendor', 'product', 'boot', 'recovery', 'vbmeta']
            
            if not self.partitions:
                # Default: extract common partitions for Pixel GSI
                self.partitions = [p.partition_name for p in manifest.partitions 
                                 if p.partition_name in pixel_partitions]
                print(f"🎯 Auto-selected Pixel partitions: {', '.join(self.partitions)}")
            
            # Use ThreadPoolExecutor for parallel extraction
            with ThreadPoolExecutor(max_workers=4) as executor:
                futures = []
                for partition in manifest.partitions:
                    if not self.partitions or partition.partition_name in self.partitions:
                        future = executor.submit(self._extract_partition, partition, payload)
                        futures.append(future)
                
                # Wait for all extractions to complete
                for future in futures:
                    future.result()
        
        print("✅ Payload extraction completed!")
        return True

def main():
    parser = argparse.ArgumentParser(description='Extract Android OTA payload.bin')
    parser.add_argument('payload', help='Path to payload.bin file')
    parser.add_argument('-o', '--output', default='.', help='Output directory')
    parser.add_argument('-p', '--partitions', nargs='+', 
                       help='Specific partitions to extract (default: auto-detect for Pixel)')
    parser.add_argument('--pixel', action='store_true',
                       help='Extract only Pixel-relevant partitions')
    
    args = parser.parse_args()
    
    # Set Pixel-specific partitions if requested
    if args.pixel:
        args.partitions = ['system', 'vendor', 'product', 'boot', 'vbmeta']
        print("🎯 Pixel mode: extracting system, vendor, product, boot, vbmeta")
    
    dumper = PayloadDumper(args.payload, args.output, args.partitions)
    success = dumper.extract()
    
    if success:
        print(f"📁 Files extracted to: {os.path.abspath(args.output)}")
        
        # Show extracted files
        extracted_files = [f for f in os.listdir(args.output) if f.endswith('.img')]
        if extracted_files:
            print("📋 Extracted files:")
            for file in sorted(extracted_files):
                size = os.path.getsize(os.path.join(args.output, file))
                print(f"  - {file} ({size:,} bytes)")
    else:
        sys.exit(1)

if __name__ == '__main__':
    main()

