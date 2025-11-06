import React, { useState, useEffect } from 'react';
import { Box, Typography, IconButton, Dialog, DialogActions, DialogContent, DialogTitle, Button, TextField, Checkbox, FormControlLabel } from '@mui/material';
import { DataGrid } from '@mui/x-data-grid';
import dataService from '../services/dataService';
import DeleteIcon from '@mui/icons-material/Delete';
import EditIcon from '@mui/icons-material/Edit';
import AddIcon from '@mui/icons-material/Add';

const CorporateAccountsPage = () => {
  const [corporateAccounts, setCorporateAccounts] = useState([]);
  const [loading, setLoading] = useState(true);
  const [deleteDialogOpen, setDeleteDialogOpen] = useState(false);
  const [accountToDelete, setAccountToDelete] = useState(null);
  const [formDialogOpen, setFormDialogOpen] = useState(false);
  const [currentAccount, setCurrentAccount] = useState(null);

  const fetchCorporateAccounts = () => {
    setLoading(true);
    dataService.getAll('corporate-accounts')
      .then(response => {
        setCorporateAccounts(response.data);
        setLoading(false);
      })
      .catch(error => {
        console.error("Failed to fetch corporate accounts:", error);
        setLoading(false);
      });
  };

  useEffect(() => {
    fetchCorporateAccounts();
  }, []);

  const handleOpenFormDialog = (account = null) => {
    setCurrentAccount(account ? { ...account } : { company_name: '', email_domain: '', discount_percentage: 0, is_active: true });
    setFormDialogOpen(true);
  };

  const handleCloseFormDialog = () => {
    setFormDialogOpen(false);
    setCurrentAccount(null);
  };

  const handleSave = async () => {
    try {
      if (currentAccount.id) {
        await dataService.update('corporate-accounts', currentAccount.id, currentAccount);
      } else {
        await dataService.create('corporate-accounts', currentAccount);
      }
      fetchCorporateAccounts();
      handleCloseFormDialog();
    } catch (error) {
      console.error("Failed to save corporate account:", error);
    }
  };

  const handleDeleteClick = (id) => {
    setAccountToDelete(id);
    setDeleteDialogOpen(true);
  };

  const handleDeleteConfirm = async () => {
    try {
      await dataService.remove('corporate-accounts', accountToDelete);
      fetchCorporateAccounts();
      setDeleteDialogOpen(false);
      setAccountToDelete(null);
    } catch (error) {
      console.error("Failed to delete corporate account:", error);
    }
  };

  const columns = [
    { field: 'id', headerName: 'ID', width: 220 },
    { field: 'company_name', headerName: 'Company Name', width: 200 },
    { field: 'email_domain', headerName: 'Email Domain', width: 200 },
    { field: 'discount_percentage', headerName: 'Discount %', type: 'number', width: 120 },
    { field: 'is_active', headerName: 'Active', type: 'boolean', width: 100 },
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
      <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', mb: 4 }}>
        <Typography variant="h4">Manage Corporate Accounts</Typography>
        <Button variant="contained" startIcon={<AddIcon />} onClick={() => handleOpenFormDialog()}>Create Account</Button>
      </Box>
      <DataGrid
        rows={corporateAccounts}
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
        <DialogContent><p>Are you sure you want to delete this corporate account?</p></DialogContent>
        <DialogActions>
          <Button onClick={() => setDeleteDialogOpen(false)}>Cancel</Button>
          <Button onClick={handleDeleteConfirm} color="error">Delete</Button>
        </DialogActions>
      </Dialog>
      <Dialog open={formDialogOpen} onClose={handleCloseFormDialog}>
        <DialogTitle>{currentAccount?.id ? 'Edit Account' : 'Create Account'}</DialogTitle>
        <DialogContent>
            {currentAccount && (
                <Box component="form" sx={{ mt: 2 }}>
                    <TextField margin="dense" label="Company Name" fullWidth value={currentAccount.company_name} onChange={(e) => setCurrentAccount({ ...currentAccount, company_name: e.target.value })} />
                    <TextField margin="dense" label="Email Domain" fullWidth value={currentAccount.email_domain} onChange={(e) => setCurrentAccount({ ...currentAccount, email_domain: e.target.value })} />
                    <TextField margin="dense" label="Discount %" type="number" fullWidth value={currentAccount.discount_percentage} onChange={(e) => setCurrentAccount({ ...currentAccount, discount_percentage: e.target.value })} />
                    <FormControlLabel control={<Checkbox checked={currentAccount.is_active} onChange={(e) => setCurrentAccount({ ...currentAccount, is_active: e.target.checked })} />} label="Active" />
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

export default CorporateAccountsPage;