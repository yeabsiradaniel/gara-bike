import React, { useState, useEffect } from 'react';
import { Box, Typography, IconButton, Dialog, DialogActions, DialogContent, DialogTitle, Button, TextField } from '@mui/material';
import { DataGrid } from '@mui/x-data-grid';
import dataService from '../services/dataService';
import DeleteIcon from '@mui/icons-material/Delete';
import EditIcon from '@mui/icons-material/Edit';

const WalletsPage = () => {
  const [wallets, setWallets] = useState([]);
  const [loading, setLoading] = useState(true);
  const [deleteDialogOpen, setDeleteDialogOpen] = useState(false);
  const [walletToDelete, setWalletToDelete] = useState(null);
  const [formDialogOpen, setFormDialogOpen] = useState(false);
  const [currentWallet, setCurrentWallet] = useState(null);

  const fetchWallets = () => {
    setLoading(true);
    dataService.getAll('wallets')
      .then(response => {
        setWallets(response.data);
        setLoading(false);
      })
      .catch(error => {
        console.error("Failed to fetch wallets:", error);
        setLoading(false);
      });
  };

  useEffect(() => {
    fetchWallets();
  }, []);

  const handleOpenFormDialog = (wallet) => {
    setCurrentWallet({ ...wallet });
    setFormDialogOpen(true);
  };

  const handleCloseFormDialog = () => {
    setFormDialogOpen(false);
    setCurrentWallet(null);
  };

  const handleSave = async () => {
    try {
      await dataService.update('wallets', currentWallet.id, { balance: currentWallet.balance });
      fetchWallets();
      handleCloseFormDialog();
    } catch (error) {
      console.error("Failed to save wallet:", error);
    }
  };

  const handleDeleteClick = (id) => {
    setWalletToDelete(id);
    setDeleteDialogOpen(true);
  };

  const handleDeleteConfirm = async () => {
    try {
      await dataService.remove('wallets', walletToDelete);
      fetchWallets();
      setDeleteDialogOpen(false);
      setWalletToDelete(null);
    } catch (error) {
      console.error("Failed to delete wallet:", error);
    }
  };

  const columns = [
    { field: 'id', headerName: 'Wallet ID', width: 220 },
    { field: 'user', headerName: 'User', width: 220, valueGetter: (value) => value ? value.email : 'N/A' },
    { field: 'balance', headerName: 'Balance', type: 'number', width: 120 },
    {
      field: 'actions',
      headerName: 'Actions',
      type: 'actions',
      width: 120,
      getActions: ({ id, row }) => [
        <IconButton color="primary" onClick={() => handleOpenFormDialog(row)}><EditIcon /></IconButton>,
        <IconButton color="error" onClick={() => handleDeleteClick(id)}><DeleteIcon /></IconButton>,
      ],
    },
  ];

  return (
    <Box sx={{ height: '85vh', width: '100%' }}>
      <Typography variant="h4" sx={{ mb: 4 }}>Manage Wallets</Typography>
      <DataGrid
        rows={wallets}
        columns={columns}
        loading={loading}
        getRowId={(row) => row.id}
        initialState={{
          pagination: {
            paginationModel: { page: 0, pageSize: 10 },
          },
        }}
        pageSizeOptions={[5, 10, 20]}
        checkboxSelection
      />
      <Dialog open={deleteDialogOpen} onClose={() => setDeleteDialogOpen(false)}>
        <DialogTitle>Confirm Deletion</DialogTitle>
        <DialogContent><p>Are you sure you want to delete this wallet?</p></DialogContent>
        <DialogActions>
          <Button onClick={() => setDeleteDialogOpen(false)}>Cancel</Button>
          <Button onClick={handleDeleteConfirm} color="error">Delete</Button>
        </DialogActions>
      </Dialog>
      <Dialog open={formDialogOpen} onClose={handleCloseFormDialog}>
        <DialogTitle>Edit Wallet</DialogTitle>
        <DialogContent>
            {currentWallet && (
                <Box component="form" sx={{ mt: 2, minWidth: 300 }}>
                    <TextField margin="dense" label="Balance" type="number" fullWidth value={currentWallet.balance} onChange={(e) => setCurrentWallet({ ...currentWallet, balance: e.target.value })} />
                </Box>
            )}
        </DialogContent>
        <DialogActions>
          <Button onClick={handleCloseFormDialog}>Cancel</Button>
          <Button onClick={handleSave}>Save</Button>
        </DialogActions>
      </Dialog>
    </Box>
  );
};

export default WalletsPage;